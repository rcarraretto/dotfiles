command! -nargs=1 -count=3 BufferFromClipboard
      \ call fromclip#BufferFromClipboard(<q-args>, <count>)
