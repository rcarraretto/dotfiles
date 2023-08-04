function! quickfix#QfConfig()
  if exists('b:qf_configured')
    " Prevent e.g. height to be reset when calling the delete operator,
    " since setqflist() triggers the 'FileType qf' autocmd.
    return
  endif
  nnoremap <buffer> <silent> t <c-w><cr><c-w>T
  nnoremap <buffer> <silent> o <cr>
  nnoremap <buffer> <silent> s :call <sid>OpenOnSplit('right')<cr>
  nnoremap <buffer> <silent> S :call <sid>OpenOnSplit('left')<cr>
  nnoremap <buffer> <silent> go <cr><c-w>j
  nnoremap <buffer> <silent> x <c-w><cr><c-w>K
  nnoremap <buffer> <silent> dd :call <sid>DeleteCurrentLine()<cr>
  nnoremap <buffer> dp :QfDeletePattern<cr>
  nnoremap <buffer> dP :QfFilterPattern<cr>
  nnoremap <buffer> gj :call <sid>OpenInIntellij()<cr>
  nnoremap <buffer> <silent> d :set operatorfunc=<sid>DeleteOperator<cr>g@
  command! -buffer QfDeletePattern call s:QfDeletePattern()
  command! -buffer QfFilterPattern call s:QfFilterPattern()
  call s:AdjustWinHeight(3, 10)
  let b:parenmatch = 0
  let b:qf_configured = 1
endfunction

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
  " use 'r' to preserve 'quickfixtextfunc'
  call setqflist(qflist, 'r')
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
  " use 'r' to preserve 'quickfixtextfunc'
  call setqflist(qflist, 'r')
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
  " use 'r' to preserve 'quickfixtextfunc'
  call setqflist(qflist, 'r')
  call setpos('.', saved_cursor)
endfunction

" From http://vim.wikia.com/wiki/Automatically_fitting_a_quickfix_window_height
function! s:AdjustWinHeight(minheight, maxheight)
  execute max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

function! quickfix#QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction

function! quickfix#TextFuncNotes(info) abort
  let items = getqflist({'id': a:info.id, 'items': 1}).items
  let qflines = []
  for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
    let item = items[idx]
    let fpath = notes#AliasNotePath(bufname(item.bufnr))
    let qfline = printf('%s|%d col %d|%s| %s',
          \fpath,
          \item.lnum,
          \item.col,
          \matchstr(item.text, '@\zs\u\+'),
          \item.text
          \)
    call add(qflines, qfline)
  endfor
  return qflines
endfunction

" Adapted from
" https://github.com/milkypostman/vim-togglelist
" https://www.reddit.com/r/vim/comments/5ulthc/how_would_i_detect_whether_quickfix_window_is_open/
function! quickfix#ToggleQuickfixList()
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
function! quickfix#ToggleLocationList()
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

" Adapted from:
" https://www.reddit.com/r/vim/comments/9iwr41/comment/e6n0qmi/
function! quickfix#WriteToFile(path) abort
  let qflist = getqflist({'all': 1})
  " important for vim restart
  call remove(qflist, 'qfbufnr')

  " replace bufnr by filename
  for idx in range(len(qflist.items))
    let item = qflist.items[idx]
    if bufexists(item.bufnr)
      let item.filename = fnamemodify(bufname(item.bufnr), ':p')
    endif
    " important for vim restart
    call remove(item, 'bufnr')
  endfor

  call writefile([js_encode(qflist)], a:path)
endfunction

function! quickfix#ReadFromFile(path) abort
  let line = get(readfile(a:path), 0, '')
  if line == ''
    return util#error_msg('QfReadFromFile: empty content')
  endif
  let qflist = js_decode(line)
  call setqflist([], ' ', qflist)
  botright copen
endfunction

function! s:OpenInIntellij() abort
  let qfitem = getqflist()[line('.')-1]
  let filename = bufname(qfitem['bufnr'])
  let lnum = qfitem['lnum']
  let path = fnamemodify(filename, ':p')
  call fs#OpenInIntellij(path, lnum)
endfunction
