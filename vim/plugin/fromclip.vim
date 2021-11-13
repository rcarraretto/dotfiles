command! -nargs=1 -count=3 BufferFromClipboard
      \ call fromclip#BufferFromClipboard(<q-args>, <count>)

command! -count=3 JsonFromClipboard
      \ call fromclip#ViewFormattedJson(getreg('*'), <count>)
command! JsonSortKeys call fromclip#JsonSortKeys()
command! TogglePreviewJsonLines call fromclip#TogglePreviewJsonLines()
