function! proglang#terraform#SearchResource() abort
  let matches = matchlist(getline('.'), '\(resource\|data\) "\([^"]\+\)" "\([^"]\+\)"')
  if len(matches) == 0
    return util#error_msg('SearchTerraformResource: cursor not on resource|data')
  endif
  let resource_type = matches[2]
  let local_name = matches[3]
  let @/ = resource_type . '.' . local_name
  try
    normal! n
    normal! zz
  catch /E486/
    return util#echo_exception()
  endtry
  " needs to be last, else exception message is overwritten
  call search#Highlight()
endfunction
