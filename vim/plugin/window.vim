command! -nargs=? -complete=file VSplitRight call window#VSplitRight(<q-args>)
command! -nargs=? -complete=file VSplitLeft call window#VSplitLeft(<q-args>)
command! BufOnly call window#BufOnly()
command! ListUnsavedBuffers call window#ListUnsavedBuffers()
