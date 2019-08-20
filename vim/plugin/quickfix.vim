function! s:OpenNewLeftSplit()
  " :h CTRL-W_<CR>
  execute "normal \<c-w>\<cr>\<c-w>H"
  cclose
  botright copen
  execute "normal \<c-w>\p"
endfunction

function! s:OpenOnLeftSplit()
  let num_wins = len(gettabinfo(tabpagenr())[0]['windows'])
  if num_wins > 2
    execute "1wincmd c"
  endif
  call s:OpenNewLeftSplit()
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
  nnoremap <buffer> <silent> t <c-w><cr><c-w>T
  nnoremap <buffer> <silent> o <cr>
  nnoremap <buffer> <silent> s :call <sid>OpenOnLeftSplit()<cr>
  nnoremap <buffer> <silent> S :call <sid>OpenNewLeftSplit()<cr>
  nnoremap <buffer> <silent> go <cr><c-w>j
  nnoremap <buffer> <silent> x <c-w><cr><c-w>K
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

function! s:FilterBySearchPattern()
  call setqflist(filter(getqflist(), "v:val['text'] =~ '" . @/ . "'"))
endfunction
command! Qfilter call s:FilterBySearchPattern()

" Adapted from
" https://github.com/milkypostman/vim-togglelist
" https://www.reddit.com/r/vim/comments/5ulthc/how_would_i_detect_whether_quickfix_window_is_open/
function! ToggleQuickfixList()
  for bufnum in map(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist'), 'v:val.bufnr')
    if bufwinnr(bufnum) != -1
      cclose
      return
    endif
  endfor
  let winnr = winnr()
  botright copen
  if winnr() != winnr
    wincmd p
  endif
endfunction
