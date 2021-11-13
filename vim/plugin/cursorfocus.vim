function! s:OnWinEnter()
  if s:ShouldCursorLine()
    setlocal cursorline
  endif
  if s:ShouldColorColumn()
    let &l:colorcolumn='0'
  endif
endfunction

function! s:OnWinLeave()
  setlocal nocursorline
  if s:ShouldColorColumn()
    let &l:colorcolumn=join(range(1, 255), ',')
  else
    let &l:colorcolumn='0'
  endif
endfunction

function! s:ShouldCursorLine()
  if get(b:, 'skip_cursor_line')
    return 0
  endif
  return index(['agit_diff', 'rc_git_diff'], &filetype) == -1
endfunction

function! s:ShouldColorColumn()
  if get(b:, 'skip_color_column')
    return 0
  endif
  return index(['qf', 'diff', 'undotree', 'agit', 'agit_stat', 'agit_diff', 'rc_git_log', 'rc_git_branches', 'rc_git_diff', 'fugitive', 'fugitiveblame'], &filetype) == -1
endfunction

augroup CursorFocus
  autocmd!
  autocmd BufEnter,FocusGained,WinEnter * call s:OnWinEnter()
  autocmd FocusLost,WinLeave * call s:OnWinLeave()
augroup END
