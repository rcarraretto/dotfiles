" Open/close a log window on the right side of the current tab
" and keep all other log windows closed.
function! vimutil#ToggleLogWindow(target_path) abort
  let paths = [
        \'/var/tmp/test-console.txt',
        \'/var/tmp/test-results.txt',
        \'/var/tmp/vim-messages.txt'
        \]
  let oldwinnr = winnr()
  let opened = util#ToggleWindowInTab(a:target_path)
  if opened == 1
    " Window was opened.
    " Keep window on the right side.
    wincmd L
    setlocal wrap
    setlocal foldlevel=20
    " Close all the other log windows.
    for path in paths
      if path != a:target_path
        call util#CloseWindowInTab(path)
      endif
    endfor
  endif
  " Go back to original window
  if winbufnr(oldwinnr) != -1
    execute oldwinnr . "wincmd w"
  endif
endfunction

function! vimutil#CloseAuxiliaryBuffers() abort
  cclose
  lclose
  " close buffers in /var/tmp:
  " - test-results.txt
  " - test-console.txt
  " - vim-messages.txt
  let bufs = filter(getbufinfo(), {idx, val -> val['listed'] && val['name'] =~ '^/private/var/tmp'})
  let bufnrs = map(bufs, 'v:val.bufnr')
  for bufnr in bufnrs
    execute "bdelete " . bufnr
  endfor
endfunction

function! vimutil#CaptureMessages()
  let messages = util#messages()
  silent call writefile(messages, '/var/tmp/test-results.txt')
  call fs#RefreshBuffer('/var/tmp/test-results.txt')
  " open test-results.txt
  let a = util#OpenWindowInTab('/var/tmp/test-results.txt', 'vs')
  wincmd L
  wincmd p
endfunction

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

" :GoToDefinition map <cr>
" :GoToDefinition function fzf#run
" :GoToDefinition hi typescriptFuncKeyword
function! vimutil#GoToDefinition(cmd)
  " Sample verbose output:
  "
  " :verbose command TsuReload
  "     Name              Args Address Complete    Definition
  " b   TsuReload         *            buffer      :call tsuquyomi#reload(<f-args>)
  "         Last set from ~/work/tsuquyomi/autoload/tsuquyomi/config.vim line 185
  "     TsuReloadProject  0                        : call tsuquyomi#reloadProject()
  "         Last set from ~/work/tsuquyomi/plugin/tsuquyomi.vim line 91
  "
  let out = util#capture('verbose ' . a:cmd)
  let lines = split(out, '\n')
  for line in lines
    let m = matchlist(line, '.*Last set from \(.*\) line \(\d\+\)')
    if !len(m)
      continue
    endif
    let filename = m[1]
    let line_num = m[2]
    silent execute 'edit ' . filename
    execute line_num
    return
  endfor
  echo substitute(out, '\n', '', '')
endfunction

" :GoToCommandDefinition AbortDispatch
function! vimutil#GoToCommandDefinition(cmd)
  if a:cmd =~ '\s'
    echo 'Not a *command*: ' . a:cmd
    return
  endif
  call vimutil#GoToDefinition('command ' . a:cmd)
endfunction

" Unlets the guard variable of the current plugin file.
"
" Example:
" if exists('g:autoloaded_fugitive')
"   finish
" endif
"
function! vimutil#DisarmPluginGuard() abort
  for i in range(1, line('$'))
    let line = getline(i)
    " Skip empty lines
    if len(line) == 0
      continue
    endif
    " Skip comments
    if match(line, '^"') >= 0
      continue
    endif
    let m = matchlist(line, '^if exists(''\(g:.*\)'')$')
    if empty(m)
      return 0
    endif
    if match(getline(i + 1), '^\s*finish$') == -1
      return 0
    endif
    let global_var_name = m[1]
    if !exists(global_var_name)
      return 0
    endif
    let cmd = "unlet " . global_var_name
    echom cmd
    execute cmd
    return global_var_name
  endfor
  return 0
endfunction

function! vimutil#CaptureRuntime() abort
  " &rtp with removed leading \n
  let rtp = util#capture('echo &rtp')[1:]
  let paths = split(rtp, ',')
  let items = map(paths, "{'filename': v:val}")
  call setqflist(items)
  botright copen
endfunction

" Populates the qf based on the output of a :verbose command.
" :verbose highlight Bold
" =>
" ~/work/dotfiles/vim/bundle/base16-vim/colors/base16-default-dark.vim line 169
function! s:VerboseToQfItems(cmd, text) abort
  let out = util#capture('verbose ' . a:cmd)
  let lines = split(out, '\n')
  let items = []
  for line in lines
    let m = matchlist(line, '.*Last set from \(.*\) line \(\d\+\)')
    if !len(m)
      continue
    endif
    let filename = fnamemodify(m[1], ':p')
    let lnum = m[2]
    call add(items, {'text': a:text, 'filename': filename, 'lnum': lnum})
  endfor
  if empty(items)
    return [{'text': a:text}]
  endif
  return items
endfunction

" Based on zS mapping from scriptease.vim
" scriptease#synnames()
function! vimutil#DebugSynStack() abort
  let elems = reverse(map(synstack(line('.'), col('.')), 'synIDattr(v:val,"name")'))
  if empty(elems)
    return util#error_msg('DebugSynStack: no elements found in current line')
  endif
  let all_qf_items = []
  for elem in elems
    let qf_items = s:VerboseToQfItems('highlight ' . elem, elem)
    let all_qf_items += qf_items
  endfor
  call setqflist(all_qf_items)
  botright copen
endfunction

function! vimutil#ExploreSyntaxFiles() abort
  let script_paths = s:GetScriptPaths()
  let paths = []
  for script_path in script_paths
    if match(script_path, 'syntax/' . &syntax . '.vim') >= 0
      call add(paths, script_path)
    endif
  endfor
  if empty(paths)
    return util#error_msg('ExploreSyntaxFiles: no syntax files found')
  endif
  let items = map(paths, "{'filename': v:val}")
  call setqflist(items)
  call window#MaybeSplit()
  cfirst
endfunction

" Get full paths from :scriptnames
function! s:GetScriptPaths() abort
   return map(split(execute('scriptnames'), "\n"), 'fnamemodify(substitute(v:val, ''^\s*\d*: '', "", ""), '':p'')')
endfunction

" Based on https://stackoverflow.com/a/38735392/2277505
function! vimutil#ListCtrlMappings() abort
  let out = util#capture('map')
  vnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  silent put =out
  silent v/^.  <C-/d
  sort
endfunction
