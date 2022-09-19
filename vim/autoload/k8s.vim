function! k8s#Setup() abort
  for line_num in range(1, line('$'))
    let line = getline(line_num)
    if line[0] ==# '#'
      continue
    endif
    if line[0:11] ==# 'apiVersion: '
      break
    endif
    return
  endfor
  setlocal foldmethod=expr
  " alternatively, use '<1' instead of '0' to make '---' be inside the fold
  setlocal foldexpr=getline(v:lnum)=='---'?'0':'1'
  setlocal foldtext=k8s#FoldText()
endfunction

" Make the fold text include the k8s resource 'kind' and 'name'
function! k8s#FoldText() abort
  let kind = ''
  let name = ''
  let curr_root_attr = ''
  for i in range(v:foldstart, v:foldend)
    let line = getline(i)
    let m = matchlist(line, '^\(\s*\)\([[:alnum:]]\+\):\s*\([[:alnum:]-]*\)')
    if empty(m)
      continue
    endif
    let space = m[1]
    let attr = m[2]
    let value = m[3]
    if empty(space)
      let curr_root_attr = attr
      if attr ==# 'kind'
        let kind = value
      endif
    elseif curr_root_attr ==# 'metadata' && attr ==# 'name'
      let name = value
    endif
  endfor
  if empty(kind) || empty(name)
    return foldtext()
  endif
  let title = kind . ' (' . name . ')'
  return substitute(foldtext(), '^\(.*lines: \).*$', '\1' . title . ' ', '')
endfunction
