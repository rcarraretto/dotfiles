" Toggle List plugin
" Adapted from https://github.com/milkypostman/vim-togglelist

function! s:OpenVs()
  execute "normal \<c-w>\<cr>\<c-w>L"
  cclose
  botright copen
  execute "normal \<c-w>\p"
endfunction

function! s:RegisterMappings()
  nnoremap <buffer> <silent> t <C-W><CR><C-W>T
  nnoremap <buffer> <silent> o <cr>
  nnoremap <buffer> <silent> go <CR><C-W>j
  nnoremap <buffer> <silent> x <C-W><CR><C-W>K
  nnoremap <buffer> <silent> s :call <sid>OpenVs()<cr>
endfunction

augroup QfMappings
  autocmd!
  autocmd FileType qf call s:RegisterMappings()
augroup END

function! s:GetBufferList()
  redir =>buflist
  silent! ls
  redir END
  return buflist
endfunction

function! ToggleLocationList()
  let curbufnr = winbufnr(0)
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Location List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if curbufnr == bufnum
      lclose
      return
    endif
  endfor

  let winnr = winnr()
  let prevwinnr = winnr("#")

  let nextbufnr = winbufnr(winnr + 1)
  try
    lopen
  catch /E776/
      echohl ErrorMsg
      echo "Location List is Empty."
      echohl None
      return
  endtry
  if winbufnr(0) == nextbufnr
    lclose
    if prevwinnr > winnr
      let prevwinnr-=1
    endif
  else
    if prevwinnr > winnr
      let prevwinnr+=1
    endif
  endif
  " restore previous window
  exec prevwinnr."wincmd w"
  exec winnr."wincmd w"
endfunction

function! ToggleQuickfixList()
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Quickfix List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      cclose
      return
    endif
  endfor
  let winnr = winnr()
  if exists("g:toggle_list_copen_command")
    exec(g:toggle_list_copen_command)
  else
    botright copen
  endif
  if winnr() != winnr
    wincmd p
  endif
endfunction
