function! proglang#vimscript#EditAlternateFile() abort
  let path = expand('%:p')
  let dir = expand('%:h:t')
  if dir !=# 'plugin' && dir !=# 'autoload'
    return util#error_msg('proglang#vimscript#EditAlternateFile: file is neither plugin or autoload')
  endif
  if dir ==# 'plugin'
    let alt_dir = 'autoload'
  else
    let alt_dir = 'plugin'
  endif
  let alt_path = expand('%:h:h') . '/' . alt_dir . '/' . expand('%:t')
  if !filereadable(alt_path)
    let ok = util#prompt('Create ' . alt_path . '?', {'type': 'info'})
    if !ok
      return
    endif
  endif
  call window#MaybeSplit()
  silent execute 'edit ' . alt_path
endfunction
