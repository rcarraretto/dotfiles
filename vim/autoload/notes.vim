if exists('s:note_configs')
  unlet s:note_configs
endif

function! notes#GetNoteConfigs() abort
  if exists('s:note_configs')
    return s:note_configs
  endif
  let configs = []
  call s:AddNoteConfig(configs, $NOTES_SHARED, '$NT_S')
  call s:AddNoteConfig(configs, $NOTES_HOME, '$NT_H')
  call s:AddNoteConfig(configs, $NOTES_WORK, '$NT_W')
  let s:note_configs = configs
  return s:note_configs
endfunction

function! s:AddNoteConfig(configs, path, alias) abort
  if empty(a:path) || !isdirectory(a:path)
    return
  endif
  call add(a:configs, {
        \'path': a:path,
        \'epath': fnameescape(a:path),
        \'alias': a:alias
        \})
endfunction

function! notes#GetNoteDirs() abort
  return join(map(copy(notes#GetNoteConfigs()), 'v:val.epath'), ' ')
endfunction

function! notes#AliasNotePath(fpath) abort
  for nc in notes#GetNoteConfigs()
    if a:fpath[0:len(nc.path)] == nc.path . '/'
      return nc.alias . a:fpath[len(nc.path):]
    endif
  endfor
  return a:fpath
endfunction
