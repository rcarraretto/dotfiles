" Based on https://stackoverflow.com/a/49345500/2277505
function! s:OpenOnSplit(direction)
  let num_wins = len(gettabinfo(tabpagenr())[0]['windows']) - 1
  " 1) on quickfix, get error number
  let qf_line_num = line('.')
  " 2) go to the active window to do the split,
  " so we clone the jumplist and alternate buffer
  if a:direction == 'left'
    1wincmd w
  else
    if num_wins == 1
      1wincmd w
    else
      2wincmd w
    endif
  endif
  " 3) split the active window
  if a:direction == 'left'
    VSplitLeft
  else
    VSplitRight
  endif
  " 4) open error in that new split
  execute qf_line_num . 'cc'
  " 5) remove old window
  if num_wins >= 2
    " if already had 2 project windows:
    " Close the cloned one, so we always have 2 project windows (left + right).
    2wincmd c
  endif
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
  nnoremap <buffer> <silent> s :call <sid>OpenOnSplit('right')<cr>
  nnoremap <buffer> <silent> S :call <sid>OpenOnSplit('left')<cr>
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
