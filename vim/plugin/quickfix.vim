" Based on https://stackoverflow.com/a/49345500/2277505
function! s:OpenNewLeftSplit()
  let qf_line_num = line('.')
  wincmd w
  VSplitLeft
  execute qf_line_num . 'cc'
endfunction

function! s:OpenOnLeftSplit()
  let num_wins = len(gettabinfo(tabpagenr())[0]['windows'])
  if num_wins > 2
    execute "1wincmd c"
  endif
  call s:OpenNewLeftSplit()
endfunction

" Adapted from https://stackoverflow.com/a/48817071/2277505
function! s:DeleteCurrentLine()
  let curqfidx = line('.') - 1
  let qfall = getqflist()
  call remove(qfall, curqfidx)
  call setqflist(qfall, 'r')
  execute curqfidx + 1 . "cfirst"
  wincmd p
endfunction

" Based on https://github.com/AndrewRadev/qftools.vim
function! s:DeleteOperator(_type) abort
  let saved_cursor = getpos('.')
  let qflist = getqflist()
  call remove(qflist, line("'[") - 1, line("']") - 1)
  call setqflist(qflist)
  call setpos('.', saved_cursor)
endfunction

" Based on https://github.com/sk1418/QFGrep
function! s:QfDeletePattern() abort
  let saved_cursor = getpos('.')

  let qflist = getqflist()

  " Loop from the last line to the first line.
  " This way, we can remove items from 'qflist'
  " without shifting the indexes.
  for line_index in reverse(range(1, line('$')))
    if getline(line_index) =~ @/
      call remove(qflist, line_index - 1)
    endif
  endfor

  call setqflist(qflist)

  call setpos('.', saved_cursor)
endfunction

" Based on https://github.com/sk1418/QFGrep
function! s:QfFilterPattern() abort
  let saved_cursor = getpos('.')

  let qflist = getqflist()

  " Loop from the last line to the first line.
  " This way, we can remove items from 'qflist'
  " without shifting the indexes.
  for line_index in reverse(range(1, line('$')))
    if getline(line_index) !~ @/
      call remove(qflist, line_index - 1)
    endif
  endfor

  call setqflist(qflist)

  call setpos('.', saved_cursor)
endfunction

function! s:QfConfig()
  nnoremap <buffer> <silent> t <c-w><cr><c-w>T
  nnoremap <buffer> <silent> o <cr>
  nnoremap <buffer> <silent> s :call <sid>OpenOnLeftSplit()<cr>
  nnoremap <buffer> <silent> S :call <sid>OpenNewLeftSplit()<cr>
  nnoremap <buffer> <silent> go <cr><c-w>j
  nnoremap <buffer> <silent> x <c-w><cr><c-w>K
  nnoremap <buffer> <silent> dd :call <sid>DeleteCurrentLine()<cr>
  nnoremap <buffer> <silent> d :set operatorfunc=<sid>DeleteOperator<cr>g@
  command! -buffer QfDeletePattern call s:QfDeletePattern()
  command! -buffer QfFilterPattern call s:QfFilterPattern()
  call s:AdjustWinHeight(3, 10)
endfunction

" From http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
function! s:AdjustWinHeight(minheight, maxheight)
  execute max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

augroup Qf
  autocmd!
  autocmd FileType qf call s:QfConfig()
augroup END

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

" Adapted from
" https://github.com/milkypostman/vim-togglelist
function! ToggleLocationList()
  let curbufnr = winbufnr(0)
  for bufnum in map(filter(getwininfo(), 'v:val.quickfix && v:val.loclist'), 'v:val.bufnr')
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
  exec prevwinnr . "wincmd w"
  exec winnr . "wincmd w"
endfunction
