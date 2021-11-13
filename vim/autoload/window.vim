function! window#MaybeSplit() abort
  if v:count == 1
    silent split
    return 1
  elseif v:count == 2
    silent vsplit
    return 1
  elseif v:count == 3
    silent tab split
    return 1
  endif
  return 0
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
