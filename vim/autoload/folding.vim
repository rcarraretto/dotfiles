function! folding#Toggle()
  if foldclosed(line('.')) == -1
    " Fold is open.
    " Close one level
    try
      normal! za
    catch /E490/
      echo 'Fold not found'
      return
    endtry
    if foldclosed(line('.')) == -1
      " Fold is still open.
      " This seems to happen when the line is the only line
      " with that fold level.
      normal! za
    endif
  else
    " Fold is closed.
    " Open folds recursively
    normal! zA
  endif
endfunction

function! folding#ResetFoldLevel()
  if index(['ntx', 'pem'], &ft) >= 0
    setlocal foldlevel=0
  else
    setlocal foldlevel=1
  endif
  normal! zz
endfunction

" Based on:
" https://stackoverflow.com/a/3264176
" https://vim.fandom.com/wiki/Search_only_over_a_visual_range
function! folding#SearchInFold() abort
  let pos = getpos('.')
  normal! [z
  let start = line('.')
  normal! ]z
  let end = line('.')
  call setpos('.', pos)
  " :help \%>l
  " :help \%<l
  let after_start = '\%>' . start . 'l'
  let before_end = '\%<' . end . 'l'
  call feedkeys('/' . after_start . before_end)
endfunction
