function! viewing#CopyCursorReference() abort
  let path = fnameescape(expand("%:~"))
  let line_num = line('.')
  let col_num = col('.')
  let @* = printf('%s:%s:%s', path, line_num, col_num)
endfunction

function! viewing#GoToCursorReference() abort
  let line = getline('.')
  let cursor = getpos('.')
  try
    let did_split = window#MaybeSplit()
    normal! gf
  catch /E447/
    if did_split
      quit
    endif
    let msg = 'GoToCursorReference: ' . matchstr(v:exception, 'Vim(normal):E447: \zs\(.*\)')
    return util#error_msg(msg)
  endtry
  let jumped_filename = expand('%:t')
  " [Note]
  " Use 'very nomagic' (\V) so that the filename is not interpreted as a regex
  " https://stackoverflow.com/a/11311701/2277505
  let regex = '\V' . jumped_filename . ':\(\d\+\)\(:\(\d\+\)\)\?'
  let matches = matchlist(line, regex)
  if empty(matches)
    return
  endif
  let target_line = matches[1]
  let target_col = matches[3]
  call cursor(target_line, target_col)
  try
    " Open folds
    normal! zO
  catch /E490/
    " No fold found
  endtry
endfunction

function! viewing#ToggleListChars()
  if &list
    setlocal nolist
  else
    setlocal list
  endif
endfunction

function! viewing#SetNoRelativeNumber(t, w) abort
  if gettabwinvar(a:t, a:w, '&number') == 1
    call settabwinvar(a:t, a:w, '&relativenumber', 0)
  endif
endfunction

function! viewing#SetRelativeNumber(t, w) abort
  if gettabwinvar(a:t, a:w, '&number') == 1
    call settabwinvar(a:t, a:w, '&relativenumber', 1)
  endif
endfunction

function! viewing#ToggleRelativeNumber() abort
  " buffers that don't have 'number' set won't be touched
  " (e.g., dirvish, fugitive, agit)

  if &number == 0
    echohl ErrorMsg
    echom "ToggleRelativeNumber: can only be triggered when 'number' is set"
    echohl NONE
    return
  endif

  if &relativenumber
    call window#GlobalWinDo('viewing#SetNoRelativeNumber')
    " update setting globally for new buffers
    set norelativenumber
  else
    call window#GlobalWinDo('viewing#SetRelativeNumber')
    " update setting globally for new buffers
    set relativenumber
  endif
endfunction

function! viewing#MoveToPrevParagraph()
  let former_line = line('.')
  " if in the middle of paragraph
  if len(getline(line('.') - 1))
    normal! {
    if line('.') == 1
      return
    endif
    normal! +
    " Sometimes doing {+ makes it go back to
    " the same line, when using folding and when
    " there are paragraphs inside the fold.
    if line('.') == former_line
      normal! {
    endif
    return
  end
  " if current line is empty
  if len(getline('.')) == 0
    normal! {
    if line('.') == 1
      return
    endif
    normal! +
    return
  end
  " if on the beginning of paragraph
  normal! {{
  if line('.') == 1
    return
  endif
  normal! +
endfunction

function! viewing#MoveToNextParagraph()
  if len(getline('.')) == 0
    normal! +
    return
  end
  normal! }+
endfunction

function! viewing#WrapCommand(cmd)
  try
    execute a:cmd
  catch /E363/
    " if the command edits a file (e.g. fzf :Files), the file may be too large.
    " E363 will be displayed along with a trace.
    " Also, the status line will not be rendered properly.
    " Ignore E363 and redraw the status line.
    call statusline#set()
  endtry
endfunction

function! viewing#DisableSyntaxForLargeFiles()
  if index(['help'], &filetype) >= 0
    return
  endif
  if line("$") > 10000
    syntax clear
  endif
endfunction

" Remove views.
" Usually call this because folding is buggy.
function! viewing#RemoveViews()
  if !util#prompt('Delete all buffers and remove views?')
    return
  endif
  " Delete all buffers first.
  " Else buffers with buggy views will save their buggy info once they unload.
  " (see AutoSaveFolds augroup)
  %bd
  let output = system('rm -rf ~/.vim/view/*')
  if v:shell_error
    echom 'RemoveViews: Error: ' . output
  else
    echom 'Views removed'
  endif
endfunction

" fugitive.vim
function! viewing#ToggleGStatus()
  if buflisted(bufname('.git/index'))
    bd .git/index
  else
    Git
    wincmd T
  endif
endfunction
