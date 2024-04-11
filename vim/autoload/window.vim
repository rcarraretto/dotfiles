function! window#MaybeSplit() abort
  if v:count == 1 || v:count == 6
    silent split
    return 1
  elseif v:count == 2 || v:count == 7
    silent vsplit
    return 1
  elseif v:count == 3 || v:count == 8
    silent tab split
    return 1
  endif
  return 0
endfunction

function! window#SplitFromCount(count) abort
  if a:count == 1
    silent new
    return 1
  elseif a:count == 2
    silent vnew
    return 1
  elseif a:count == 3
    tabnew
    return 1
  endif
  return 0
endfunction

function! window#EditFile(path) abort
  call window#MaybeSplit()
  if bufnr(a:path) == -1
    silent execute 'edit ' . a:path
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      silent execute 'edit ' . a:path
    else
      call win_gotoid(wins[0])
    endif
  endif
endfunction

function! window#EditFileUpwards(filename) abort
  if filereadable(a:filename)
    " When exploring the root folder with Dirvish and
    " the file is at the root.
    " findfile() does not seem to work with Dirvish in that case.
    call window#EditFile(a:filename)
    return
  endif
  " Search from the directory of the current file upwards, until the home folder
  let path = findfile(a:filename, '.;' . $HOME)
  if !empty(path)
    call window#EditFile(path)
    return
  endif
  " Search from cwd upwards, until the home folder.
  " This might help in case the current file is outside of cwd (e.g. a Dropbox note).
  let path = findfile(a:filename, getcwd() . ';' . $HOME)
  if !empty(path)
    call window#EditFile(path)
    return
  endif
  echo 'File not found: ' . a:filename
endfunction

function! window#VSplitRight(path) abort
  " backup
  let prev = &splitright
  " split
  if prev == 0
    set splitright
  endif
  execute "vsplit " . a:path
  " restore
  if prev == 0
    set nosplitright
  endif
endfunction

function! window#VSplitLeft(path) abort
  " backup
  let prev = &splitright
  " split
  if prev == 1
    set nosplitright
  endif
  execute "vsplit " . a:path
  " restore
  if prev == 1
    set splitright
  endif
endfunction

function! s:HighestWinnr()
  let wins = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == tabpagenr()')
  return wins[-1]['winnr']
endfunction

function! window#CycleWinDownOrNext() abort
  let prev_winnr = winnr()
  wincmd j
  if prev_winnr == winnr()
    " Can move from B to C
    "   A  |  C
    " -----|
    "  *B* |
    "
    wincmd w
  endif
endfunction

function! window#CycleWinUpOrPrev() abort
  let prev_winnr = winnr()
  wincmd k
  if prev_winnr == winnr()
    " Can move from C to B
    " ('wincmd h' will move from C to A sometimes, depending on
    "  where you are on C)
    "   A  | *C*
    " -----|
    "   B  |
    "
    wincmd W
  endif
endfunction

function! window#CycleWinLeft()
  if winnr() == 1
    " This is the first window.
    " Go to the last window.
    " (i.e., cycle instead of moving left)
    "
    " This is a possible layout:
    "  *A* |  B
    " -----------
    "   C  |  D
    "
    " In this case, it moves from A to D.
    execute s:HighestWinnr() . "wincmd w"
  else
    " Move left
    let prev_winnr = winnr()
    execute "normal! \<c-w>h"
    if winnr() == prev_winnr
      " Couldn't move left.
      " This is likely the layout:
      "   A  |  B
      " -----------
      "  *C* |  D
      "
      " In this case, move from C to B.
      execute "normal! \<c-w>w"
    endif
  endif
endfunction

function! window#CycleWinRight()
  if winnr() == s:HighestWinnr()
    " This is the last 'normal' window.
    " Go back to window #1.
    " (i.e., cycle instead of moving right)
    1 wincmd w
  else
    let prev_winnr = winnr()
    " Move right
    execute "normal! \<c-w>l"
    if winnr() == prev_winnr
      " Couldn't move right.
      " This is likely the layout:
      "   A  | *B*
      " -----------
      "   C  |  D
      "
      " In this case, move from B to C.
      execute "normal! \<c-w>W"
    endif
  endif
endfunction

function! window#ToggleWindowSize() abort
  if &columns - winwidth(0) < 10
    " if the size of the current window is close enough to the size of the
    " terminal, make window sizes even.
    "
    " Note: The size of the current window and the terminal will not exactly
    " match when other windows were pushed away via 'wincmd _' and 'wincmd |'.
    " The other windows are shrinked to be ~1 column long.
    wincmd =
  else
    " maximize size of current window
    wincmd _
    wincmd |
  endif
endfunction

" Similar to :quit but try to land on the previous window.
" https://vi.stackexchange.com/a/9232
function! window#CloseWindow() abort
  call undoquit#SaveWindowQuitHistory()
  let prev_win_nr = winnr()
  wincmd p
  execute prev_win_nr . "wincmd q"
endfunction

" Similar to :tabclose but land on the last accessed tab.
function! window#CloseTab() abort
  let prev_tab_nr = tabpagenr()
  " Go to last accessed tab
  execute "normal! g\<tab>"
  try
    execute 'tabclose ' . prev_tab_nr
  catch
    echohl ErrorMsg
    echom v:exception
    echohl NONE
  endtry
endfunction

function! window#CloseUnlistedBuffersInTab() abort
  let wins = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == tabpagenr()')
  for win in wins
    if getbufinfo(win['bufnr'])[0]['listed'] == 0
      call win_gotoid(win['winid'])
      noautocmd wincmd c
    endif
  endfor
endfunction

function! window#ListUnsavedBuffers()
  let bufs = filter(getbufinfo(), {idx, val -> val['changed']})
  let bufitems = map(bufs, '{"filename": v:val.name, "lnum": v:val.lnum}')
  call setqflist(bufitems)
  if empty(bufitems)
    cclose
    echo 'No unsaved buffers'
    return
  endif
  botright copen
endfunction

function! window#BufOnly()
  for n in range(1, bufnr('$'))
    if n == bufnr('%') || !bufexists(n)
      continue
    endif
    silent execute 'bwipeout ' . n
  endfor
endfunction

" Executes callback function for all windows.
"
" based on https://vi.stackexchange.com/a/12068
"
function! window#GlobalWinDo(callback) abort
  for t in range(1, tabpagenr('$'))
    for w in range(1, tabpagewinnr(t, '$'))
      call function(a:callback)(t, w)
    endfor
  endfor
endfunction
