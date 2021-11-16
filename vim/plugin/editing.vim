augroup TrimWhitespace
  autocmd!
  autocmd BufWritePre * call editing#TrimWhitespace()
augroup END
