augroup SetStatusline
  autocmd!
  autocmd BufEnter,FocusGained,WinEnter * call statusline#set()
  autocmd FocusLost,WinLeave * call statusline#set(0)
  " when calling setqflist(), the status line is reset
  autocmd FileType qf call statusline#set()
augroup END
