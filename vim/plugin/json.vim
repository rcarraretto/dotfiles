command! -count=3 JsonFromClipboard
      \ call json#ViewFormattedJson(getreg('*'), <count>)
command! TogglePreviewJsonLines call json#TogglePreviewJsonLines()

augroup JsonConfig
  autocmd!
  autocmd FileType json call json#JsonConfig()
augroup END
