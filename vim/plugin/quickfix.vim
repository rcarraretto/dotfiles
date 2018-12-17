function! s:OpenVs()
  execute "normal \<c-w>\<cr>\<c-w>L"
  cclose
  botright copen
  execute "normal \<c-w>\p"
endfunction

" Adapted from https://stackoverflow.com/a/48817071/2277505
function! s:RemoveQFItem()
  let curqfidx = line('.') - 1
  let qfall = getqflist()
  call remove(qfall, curqfidx)
  call setqflist(qfall, 'r')
  execute curqfidx + 1 . "cfirst"
  wincmd p
endfunction

function! s:RegisterMappings()
  nnoremap <buffer> <silent> t <C-W><CR><C-W>T
  nnoremap <buffer> <silent> o <cr>
  nnoremap <buffer> <silent> go <CR><C-W>j
  nnoremap <buffer> <silent> x <C-W><CR><C-W>K
  nnoremap <buffer> <silent> s :call <sid>OpenVs()<cr>
  nnoremap <buffer> <silent> dd :call <sid>RemoveQFItem()<cr>
endfunction

" From http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
function! s:AdjustWinHeight(minheight, maxheight)
  execute max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

augroup Qf
  autocmd!
  autocmd FileType qf call s:RegisterMappings() | call s:AdjustWinHeight(3, 10)
augroup END

" Toggle List plugin {{{
" Adapted from https://github.com/milkypostman/vim-togglelist
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

function! ToggleQuickfixList(...)
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Quickfix List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      cclose
      return
    endif
  endfor
  let winnr = winnr()
  if a:0 ==# 1 && a:1['split'] ==# 'v'
    exec "normal :copen\<cr>\<c-w>L"
  else
    botright copen
  endif
  if winnr() != winnr
    wincmd p
  endif
endfunction
" }}}
