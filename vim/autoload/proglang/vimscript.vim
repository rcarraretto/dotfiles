function! proglang#vimscript#EditAlternateFile() abort
  let path = expand('%:p')
  let matches = matchlist(expand('%:p'), '\(.*/\)\(plugin\|autoload\)\(/.*\)')
  if len(matches) == 0
    return util#error_msg('proglang#vimscript#EditAlternateFile: file is neither plugin or autoload')
  endif
  if matches[2] ==# 'plugin'
    let alt_dir = 'autoload'
  else
    let alt_dir = 'plugin'
  endif
  let alt_path = matches[1] . alt_dir . matches[3]
  if !filereadable(alt_path)
    let ok = util#prompt('Create ' . alt_path . '?', {'type': 'info'})
    if !ok
      return
    endif
  endif
  call window#MaybeSplit()
  silent execute 'edit ' . alt_path
endfunction
