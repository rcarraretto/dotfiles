augroup SetStatusline
  autocmd!
  autocmd BufEnter * call statusline#Set()
  " when calling setqflist(), the status line is reset
  autocmd FileType qf call statusline#Set()
augroup END
