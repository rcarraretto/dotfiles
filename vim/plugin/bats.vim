augroup BatMappings
  autocmd!
  autocmd BufNewFile,BufRead *.bats call bats#AddMappings()
    \| setlocal foldmethod=marker
    \| setlocal foldmarker={,}
    \| setlocal foldlevel=0
augroup END
