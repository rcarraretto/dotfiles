command! -nargs=? -complete=file VSplitLeft call window#VSplitLeft(<q-args>)
command! BufOnly call window#BufOnly()

