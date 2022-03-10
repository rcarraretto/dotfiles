function! arglist#AddOrRemoveCurrentBuffer() abort
  let current_path = expand('%:p')
  for path in argv()
    if fnamemodify(path, ':p') == current_path
      echom 'Buffer removed from arglist'
      argdelete %
      return
    endif
  endfor
  echom 'Buffer added to arglist'
  argadd
endfunction

" Populate the arglist from a 'table of contents' file that has a list of paths
" http://vimcasts.org/episodes/populating-the-arglist/
function! arglist#ReadArglist(toc_path) abort
  if isdirectory(a:toc_path)
    return util#error_msg('Cannot be a directory: ' . a:toc_path)
  endif
  if !filereadable(a:toc_path)
    return util#error_msg('File does not exist: ' . a:toc_path)
  endif
  " caveat: paths inside TOC cannot use ~
  execute printf('args `cat %s`', fnameescape(a:toc_path))
  " :args will edit the first file, so go back to the alternative buffer
  execute "normal \<c-^>"
endfunction

function! arglist#WriteArglist(toc_path) abort
  if filereadable(a:toc_path)
    if !util#prompt(printf("Overwrite %s?", a:toc_path), {'type':'none'})
      return
    endif
  endif
  let absolute_paths = map(argv(), "fnamemodify(v:val, ':p')")
  call writefile(absolute_paths, a:toc_path)
endfunction

function! arglist#ArglistToQf() abort
  if argc() == 0
    return util#error_msg('Empty arglist')
  endif
  call setqflist(map(argv(), "{'filename': v:val}"))
  let winnr = winnr()
  botright copen
  if winnr() != winnr
    wincmd p
  endif
  cfirst
endfunction
