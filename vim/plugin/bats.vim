augroup BatMappings
  autocmd!
  autocmd BufNewFile,BufRead *.bats call bats#AddMappings()
augroup END
