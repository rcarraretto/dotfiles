" Access script-scope function
" https://stackoverflow.com/a/39216373/2277505
function! vimutil#GetScriptFunc(scriptpath, funcname)
  let scriptnames = split(execute('scriptnames'), "\n")
  let scriptnames_line = matchstr(scriptnames, '.*' . a:scriptpath)
  if empty(scriptnames_line)
    echom "GetScriptFunc: Script not found: " . a:scriptpath
    return
  endif
  let snr = matchlist(scriptnames_line, '^\s*\(\d\+\)')[1]
  if empty(snr)
    echom "GetScriptFunc: Script number not found: " . scriptnames_line
    return
  endif
  let full_funcname = '<SNR>' . snr . '_' . a:funcname
  try
    return function(full_funcname)
  catch /E700/
    echom "GetScriptFunc: Function not found: " . full_funcname
  endtry
endfunction
