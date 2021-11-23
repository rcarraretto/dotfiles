command! -nargs=1 -complete=command WrapCommand call viewing#WrapCommand(<q-args>)
command! RemoveViews call viewing#RemoveViews()
command! TagsGen call viewing#TagsGen()

augroup StartAtLastCursorPosition
  autocmd!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  "
  " g`" -> go to double quote mark -> last cursor position
  " :h `quote
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   execute "normal! g`\"" |
        \ endif
augroup END

augroup DisableSyntaxForLargeFiles
  autocmd!
  autocmd BufWinEnter * call viewing#DisableSyntaxForLargeFiles()
augroup END

if exists('$TMUX')
  augroup TmuxGitStatus
    " Refresh tmux status bar, since it shows git branch information.
    " Each buffers has its own current working directory.
    autocmd!
    autocmd BufEnter,DirChanged * silent call system('tmux refresh-client -S')
  augroup END
endif
