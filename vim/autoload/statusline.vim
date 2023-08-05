" Apparently %f doesn't always show the relative filename
" https://stackoverflow.com/a/45244610/2277505
" :h filename-modifiers
" :~ => Reduce file name to be relative to the home directory
" :. => Reduce file name to be relative to current directory
" expand('%:~:.') =>
" - expands the name of the current file, but prevents the expansion of the tilde (:~)
" - makes the path relative to the current working directory (:.)
let s:expansions = '%' . notes#ExpansionToAlias() . ':~:.'

function! statusline#CwdContext() abort
  if win_getid() != g:actual_curwin
    return ''
  endif
  " show last path component of cwd
  return '[' . fnamemodify(getcwd(), ':t') . '] '
endfunction

function! statusline#Qftitle()
  return getqflist({'title': 1}).title
endfunction

function! statusline#FmtFilepath() abort
  if win_getid() == g:actual_curwin
    " truncate file path when window is active and on a vsplit,
    " as the statusline has several other elements in it.
    if winwidth('.') <= 92
      let max_path_length = '.45'
    elseif winwidth('.') <= 120
      let max_path_length = '.60'
    else
      let max_path_length = ''
    endif
  else
    " when window is inactive, we have less elements in the statusline
    " and therefore it's OK to display the path without truncating it.
    let max_path_length = ''
  endif
  return '%' . max_path_length . "{expand('" . s:expansions . "')} "
endfunction

function! statusline#ExtendedFileInfo() abort
  let str = ''
  " <SNR>
  if get(g:, 'statusline_show_ext_info', 0)
    let str .= printf(' | win %s', tabpagewinnr(tabpagenr()))
    let str .= printf(' | buf %s', bufnr())
    if &filetype == 'vim' && &rtp =~ 'scriptease'
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

function! s:FmtLineNums()
  let length = len(string(line('$')))
  if length < 4
    let length = 4
  endif
  let line_min_max = length . '.' . length
  " line number / number of lines
  " e.g. %4.4l/%-4.4L
  return '%' . line_min_max . 'l/%-' . line_min_max . 'L '
endfunction

function! statusline#FmtRightmost() abort
  let fmt='%=' " left/right separator
  if win_getid() == g:actual_curwin
    if winwidth('.') > 50
      let fmt .= '%{statusline#ExtendedFileInfo()} | ' . s:FmtLineNums() . ' | col %-3.v '
    endif
  else
    if &filetype == 'qf'
      let fmt .= ' | ' . s:FmtLineNums() . ' | '
    endif
    let fmt .= 'win %{tabpagewinnr(tabpagenr())}   ' " window number
  endif
  return fmt
endfunction

function! s:IsSymLink() abort
  " /path/to/something/ => /path/to/something
  let path = substitute(expand('%'), '\(.*\)/$', '\1', '')
  return path != resolve(expand('%'))
endfunction

function! s:SetHelp() abort
  setlocal statusline=%f\ %{%statusline#FmtRightmost()%}
endfunction

function! s:SetQf() abort
  " %f -> '[Quickfix List]' or '[Location List]'
  setlocal statusline=%{statusline#CwdContext()}%f\ %{statusline#Qftitle()}%{%statusline#FmtRightmost()%}
endfunction

function! s:SetStd() abort
  setlocal statusline=%{statusline#CwdContext()}%{%statusline#FmtFilepath()%}
  if !get(b:, 'statusline_skip_flags')
    setlocal statusline+=%m " modified flag [-]
    setlocal statusline+=%r " readonly flag [RO]
    if s:IsSymLink()
      " display [@] for symlinks
      " (@ is inspired by 'ls' notation)
      setlocal statusline+=[@]
    endif
  endif
  setlocal statusline+=%{%statusline#FmtRightmost()%}
endfunction

function! statusline#Set()
  if &filetype == 'diff'
    return
  endif
  if &filetype == 'help'
    return s:SetHelp()
  endif
  if &filetype == 'qf'
    return s:SetQf()
  endif
  return s:SetStd()
endfunction
