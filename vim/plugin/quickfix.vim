augroup QfConfig
  autocmd!
  autocmd FileType qf call quickfix#QfConfig()
augroup END

" Populate the arglist with the filenames from the quickfix list
command! -nargs=0 -bar Qargs execute 'args ' . quickfix#QuickfixFilenames()
