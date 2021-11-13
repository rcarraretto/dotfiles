command! -nargs=1 -complete=file RenameFile call fs#RenameFile(<q-args>)
command! -nargs=? -complete=file SysOpen call fs#SysOpen(<q-args>)

function! s:OverwriteEunuchPlugin()
  " Overwrite eunuch.vim :Delete and :Remove
  command! Delete call fs#DeleteCurrentFile()
  command! Remove Delete
endfunction

augroup OverwriteEunuchPlugin
  autocmd!
  autocmd VimEnter * call s:OverwriteEunuchPlugin()
augroup END

augroup DisableE211
  autocmd!
  autocmd FileChangedShell * call fs#FileChangedShell(expand("<afile>:p"))
augroup END
