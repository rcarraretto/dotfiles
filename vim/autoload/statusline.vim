function! Qftitle()
  return getqflist({'title': 1}).title
endfunction

function! s:SetStatuslineSeparator() abort
  setlocal statusline+=\ \|\ " separator
endfunction

function! s:SetStatuslineLineNums()
  let length = len(string(line('$')))
  if length < 4
    let length = 4
  endif
  let line_min_max = length . "." . length
  " line number / number of lines
  " e.g. %4.4l/%-4.4L
  execute "setlocal statusline+=%" . line_min_max . "l/%-" . line_min_max . "L"
  setlocal statusline+=\  " separator
endfunction

function! GetCwdContext() abort
  " show last path component of cwd
  return '[' . fnamemodify(getcwd(), ':t') . '] '
endfunction

function! GetExtendedFileInfo() abort
  let str = ''
  " <SNR>
  if get(g:, 'statusline_show_ext_info', 0)
    let str .= printf(' | win %s', tabpagewinnr(tabpagenr()))
    let str .= printf(' | buf %s', bufnr())
    if &ft == 'vim' && &rtp =~ 'scriptease'
      let script_id = scriptease#scriptid('%')
      if empty(script_id)
        " e.g. script in autoload folder was not loaded yet
        let script_id = '?'
      endif
      let str .= printf(' | <SNR>%s', script_id)
    endif
  endif
  if &list == 0
    return str
  endif
  " fileencoding
  if !empty(&fileencoding)
    let str .= printf(' | %s', &fileencoding)
  endif
  " indentation
  let type = &expandtab ? '<space>' : '<tab>'
  if &softtabstop == 0
    if &tabstop == &shiftwidth
      let length = &tabstop
    else
      let length = printf('ts: %s sw: %s', &tabstop, &shiftwidth)
    endif
  else
    let length = printf('ts: %s sts: %s sw: %s', &tabstop, &softtabstop, &shiftwidth)
  endif
  let str .=  printf(' | %s %s', type, length)
  " filetype
  if !empty(&filetype)
    let str .= printf(' | %s', &filetype)
  endif
  return str
endfunction

function! statusline#set(...)
  if index(['diff', 'undotree'], &filetype) >= 0
    return
  endif
  setlocal statusline=
  let isActiveWindow = get(a:, 1, 1)
  if isActiveWindow && index(['help'], &filetype) == -1
    setlocal statusline+=%{GetCwdContext()}
  endif
  let showRelativeFilename = index(['qf', 'help'], &filetype) == -1
  if showRelativeFilename
    " Apparently %f doesn't always show the relative filename
    " https://stackoverflow.com/a/45244610/2277505
    " :h filename-modifiers
    " :~ => Reduce file name to be relative to the home directory
    " :. => Reduce file name to be relative to current directory
    " expand('%:~:.') =>
    " - expands the name of the current file, but prevents the expansion of the tilde (:~)
    " - makes the path relative to the current working directory (:.)
    if isActiveWindow
      " truncate file path when window is active and on a vsplit,
      " as the statusline has several other elements in it.
      if winwidth('.') <= 92
        let max_path_length = ".45"
      elseif winwidth('.') <= 120
        let max_path_length = ".60"
      else
        let max_path_length = ""
      endif
    else
      " when window is inactive, we have less elements in the statusline
      " and therefore it's OK to display the path without truncating it.
      let max_path_length = ""
    endif
    execute "setlocal statusline+=%" . max_path_length . "{expand('%:~:.')}"
    setlocal statusline+=\  " separator
  else
    setlocal statusline+=%f\  " filename
  endif
  let showFlags = (index(['qf', 'help'], &filetype) == -1) && !get(b:, 'statusline_skip_flags')
  if showFlags
    setlocal statusline+=%m  " modified flag
    setlocal statusline+=%r  " read only flag
  endif
  if &ft == 'qf'
    setlocal statusline+=%{Qftitle()}
  endif
  let showSymLink = index(['help', 'fugitive', 'git'], &filetype) == -1
  if showSymLink
    " /path/to/something/ => /path/to/something
    let path = substitute(expand('%'), '\(.*\)/$', '\1', '')
    if path !=# resolve(expand('%'))
      setlocal statusline+=[@]
    endif
  endif
  setlocal statusline+=%=  " left/right separator
  if isActiveWindow && winwidth('.') > 50
    setlocal statusline+=%{GetExtendedFileInfo()}
    call s:SetStatuslineSeparator()
    call s:SetStatuslineLineNums()  " line number / number of lines
    call s:SetStatuslineSeparator()
    setlocal statusline+=col\ %-3.v " column number
    setlocal statusline+=\  " separator
  elseif !isActiveWindow
    if &ft == 'qf'
      call s:SetStatuslineSeparator()
      call s:SetStatuslineLineNums()  " line number / number of lines
      call s:SetStatuslineSeparator()
    endif
    setlocal statusline+=win\ %{tabpagewinnr(tabpagenr())} " window number
    setlocal statusline+=\ \ \  " separator
  endif
endfunction
