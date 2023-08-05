function! s:ExploreProject(edit_cmd, selection) abort
  let path = a:selection[0]
  execute a:edit_cmd . ' ' . path . " | lcd " . path
endfunction

function! s:ToxLog(selection) abort
  let path = a:selection[0]
  execute 'ToxLog ' . path
endfunction

function! s:FzfExplorePaths(cmd) abort
  let action = {
        \ '': function('s:ExploreProject', ['edit']),
        \ 'ctrl-t': function('s:ExploreProject', ['tabedit']),
        \ 'ctrl-x': function('s:ExploreProject', ['split']),
        \ 'ctrl-v': function('s:ExploreProject', ['vsplit']),
        \ 'ctrl-f': function('fs#FzfSysOpenFolder'),
        \ 'ctrl-l': function('s:ToxLog'),
        \ }
  call s:FzfWithAction({'source': a:cmd}, action)
endfunction

function! fzfutil#FzfExploreProjects() abort
  call s:FzfExplorePaths('projects-ls')
endfunction

" Put custom actions, instead of using g:fzf_action.
" Based on fzf#wrap().
function! s:FzfWithAction(opts, action) abort
  let opts = a:opts
  let opts['down'] = '~40%'
  if !has_key(opts, 'options')
    let opts.options = []
  endif
  call add(opts.options, '--expect')
  call add(opts.options, join(keys(a:action), ','))
  function! opts.sinklist(lines) abort closure
    " Example of a:lines
    " ['', 'path/to/file'] (when enter was pressed)
    " ['ctrl-t', 'path/to/file']
    "
    " Adapted from fzf.vim s:common_sink
    " find $BREW_PREFIX/Cellar/fzf -name 'fzf.vim'
    let key = remove(a:lines, 0)
    let Cmd = get(a:action, key)
    return Cmd(a:lines)
  endfunction
  call fzf#run(opts)
endfunction

function! s:FzfActionNote(original_cmd, selection) abort
  let path = fnamemodify(a:selection[0], notes#ExpansionToPath())
  if type(a:original_cmd) == 2
    call a:original_cmd([path])
    return
  endif
  execute a:original_cmd . ' ' . path
endfunction

function! fzfutil#FzfNotes(all) abort
  if a:all
    let cmd = 'notes-ls --all'
    let prompt = '[notes(all)] '
  else
    let cmd = 'notes-ls'
    let prompt = '[notes] '
  endif
  let action = {
        \'': function('s:FzfActionNote', ['edit'])
        \}
  for k in keys(g:fzf_action)
    let action[k] = function('s:FzfActionNote', [g:fzf_action[k]])
  endfor
  call s:FzfWithAction({
        \'source': cmd,
        \'options': ['--prompt', prompt]
        \}, action)
endfunction

function! fzfutil#FzfDotfiles() abort
  let cmd = 'ag -g "" --hidden ' . util#GetDotfilesDirs() . ' | sed "s|^$HOME|~|"'
  call fzf#run(fzf#wrap({'source': cmd, 'options': ['--prompt', '[dotfiles*] ']}))
endfunction

function! fzfutil#FzfExploreNodeModules() abort
  if !isdirectory(getcwd() . '/node_modules')
    return util#error_msg('FzfExploreNodeModules: No node modules found in ' . getcwd())
  endif
  let cmd = 'find node_modules -mindepth 1 -maxdepth 1'
  call s:FzfExplorePaths(cmd)
endfunction

function! fzfutil#FzfExploreVimBundle() abort
  call s:FzfExplorePaths('find ~/.vim/bundle -mindepth 1 -maxdepth 1')
endfunction

function! fzfutil#FzfCurrentFolderNonRecursive(folder) abort
  " https://unix.stackexchange.com/a/104803
  let cmd = '(cd ' . fnameescape(a:folder) . ' && find . -mindepth 1 -maxdepth 1 -type f | cut -c 3-)'
  let prompt = '[CurrentFolder] ' . a:folder . '/'
  function! s:FzfCurrentFolderEdit(edit_cmd, selection) abort closure
    let path = a:folder . '/' . a:selection[0]
    execute a:edit_cmd . ' ' . path
  endfunction
  let action = {
        \ '': function('s:FzfCurrentFolderEdit', ['edit']),
        \ 'ctrl-t': function('s:FzfCurrentFolderEdit', ['tabedit']),
        \ 'ctrl-x': function('s:FzfCurrentFolderEdit', ['split']),
        \ 'ctrl-v': function('s:FzfCurrentFolderEdit', ['vsplit']),
        \ }
  call s:FzfWithAction({'source': cmd, 'options': ['--prompt', prompt]}, action)
endfunction

function! fzfutil#FzfArglist() abort
  if argc() == 0
    return util#error_msg('FzfArglist: Empty arglist')
  endif
  let paths_relative_to_cwd = map(argv(), "fnamemodify(v:val, ':.')")
  call fzf#run(fzf#wrap('args', {
        \'source': paths_relative_to_cwd,
        \'down': '~25%',
        \'options': ['--prompt', '[arglist] ']
        \}))
endfunction

function! fzfutil#FzfCwdFiles() abort
  if !empty(v:count)
    call fzf#run(fzf#wrap({
          \'source': 'fd --type directory --strip-cwd-prefix',
          \'options': ['--prompt', '[folders] ']
          \}))
  else
    WrapCommand Files
  endif
endfunction

function! fzfutil#FzfDirsOnly(dir) abort
  if !isdirectory(a:dir)
    return util#error_msg('FzfDirsOnly: invalid directory: ' . a:dir)
  endif
  let cmd = 'fd --type directory . ' . shellescape(a:dir)
  let prompt = printf('[%s] ', a:dir)
  call fzf#run(fzf#wrap({
        \'source': cmd,
        \'options': ['--prompt', prompt]
        \}))
endfunction
