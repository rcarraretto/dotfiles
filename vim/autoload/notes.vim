if exists('s:note_configs')
  unlet s:note_configs
endif

function! s:AddNoteConfig(configs, path, alias) abort
  if empty(a:path)
    return
  endif
  call add(a:configs, {
        \'path': a:path,
        \'epath': fnameescape(a:path),
        \'alias': a:alias
        \})
endfunction

let s:note_configs = []
call s:AddNoteConfig(s:note_configs, $NOTES_SHARED, '$NOTES_SHARED')
call s:AddNoteConfig(s:note_configs, $NOTES_HOME, '$NOTES_HOME')
call s:AddNoteConfig(s:note_configs, $NOTES_WORK, '$NOTES_WORK')

" Shorten ~/Library/CloudStorage/... paths
function! notes#ExpansionToAlias() abort
  let expansions = ''
  for c in s:note_configs
    let expansions .= printf(':s?%s/?%s/?', c['path'], c['alias'])
  endfor
  return expansions
endfunction

function! notes#ExpansionToPath() abort
  let expansions = ''
  for c in s:note_configs
    let expansions .= printf(':s?%s/?%s/?', c['alias'], c['path'])
  endfor
  return expansions
endfunction

function! notes#GetNoteDirs() abort
  return join(map(copy(s:note_configs), 'v:val.epath'), ' ')
endfunction

function! notes#AliasNotePath(fpath) abort
  for nc in s:note_configs
    if a:fpath[0:len(nc.path)] == nc.path . '/'
      return nc.alias . a:fpath[len(nc.path):]
    endif
  endfor
  return a:fpath
endfunction
