function! proglang#cpp#PrintCurrentFuncNameCpp() abort
  let winview = winsaveview()
  " go to top of method. cursor will be on {
  noautocmd normal [m
  if match(getline('.'), '^\s*{') >= 0
    " {'s are on a dedicated line
    normal! k
  endif
  if stridx(getline('.'), '(') == -1
    " method definition too long
    if stridx(getline('.'), ')') >= 0
      normal! f)
      normal! %
    endif
  endif
  let line = getline('.')
  noautocmd execute "normal \<c-o>"
  " fix scroll position that was changed by <c-o>
  call winrestview(winview)
  " Extract method name only (no return value or args)
  let method_name = matchstr(trim(line), '.* \zs[^(]\+\ze(')
  if len(method_name)
    echo method_name
    return
  endif
  " Couldn't find it via [m, so maybe it is inside a function.
  "
  " The [{ motion will only work if the current line is an expression
  " directly inside the function (not nested in an if, switch, etc).
  " Therefore, better to jump to a candidate location, then to print
  " inaccurate info.
  call util#error_msg("Method not found. Jumping to block...")
  normal! [{
  normal! zz
endfunction
