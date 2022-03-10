command! -nargs=1 -complete=file ReadArglist call arglist#ReadArglist(<q-args>)
command! -nargs=1 -complete=file WriteArglist call arglist#WriteArglist(<q-args>)
command! -nargs=0 ArglistToQf call arglist#ArglistToQf()
