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
