" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Side note:
" The :Ack command from ack.vim uses -complete=files,
" which causes <q-args> to expand characters like # and % (unless you escape them).
" For this reason, this :Ag command doesn't use file completion.
command! -nargs=* Ag call ag#Ag(<q-args>)
command! -nargs=* SearchInFile call ag#SearchInFile(<q-args>)
command! -nargs=* SearchNotes call ag#SearchNotes(<q-args>)
command! -nargs=* SearchDotfiles call ag#SearchDotfiles(<q-args>)
command! -nargs=* SearchInGitRoot call ag#SearchInGitRoot(<q-args>)
command! -nargs=* SearchArglist call ag#SearchArglist(<q-args>)
command! -nargs=1 SearchExtension call ag#SearchExtension(<q-args>)
