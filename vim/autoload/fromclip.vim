function! s:UnpackJsonStr(str) abort
  let str = a:str[1:-2]
  let str = substitute(str, '\\"', '"', 'g')
  let str = substitute(str, '\\n', "\n", 'g')
  return str
endfunction

" Opens a buffer with the contents of the clipboard.
" Formats content if possible.
function! fromclip#BufferFromClipboard(ft, split_count) abort
  call window#SplitFromCount(a:split_count)
  let str = trim(getreg('*'))
  if a:ft == 'xml' && str[0] == '"' && str[-1:] == '"'
    let str = s:UnpackJsonStr(str)
  endif
  call setline(1, str)
  let &ft = a:ft
  Prettier
endfunction
