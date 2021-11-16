command! -nargs=1 -complete=command WrapCommand call viewing#WrapCommand(<q-args>)
command! RemoveViews call viewing#RemoveViews()

augroup DisableSyntaxForLargeFiles
  autocmd!
  autocmd BufWinEnter * call viewing#DisableSyntaxForLargeFiles()
augroup END
