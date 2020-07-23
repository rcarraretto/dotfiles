function! util#GetGitRoot(...)
  " GetGitRoot()     => in relation to current buffer
  " GetGitRoot(path) => in relation to given path
  let path = get(a:, 1, expand('%:p'))
  " Resolves symbolic links
  let resolved_path = resolve(path)
  if isdirectory(resolved_path)
    " dirvish
    let dir = resolved_path
  else
    " dir of current file
    let dir = fnamemodify(resolved_path, ':h')
    if len(dir) == 0
      " e.g. netrw
      return 0
    endif
  endif
  let git_root_path = system('cd ' . fnameescape(dir) . ' && git rev-parse --show-toplevel')
  if v:shell_error
    return 0
  endif
  " Remove null character at the end of output
  let git_root_path = substitute(git_root_path, '\%x00$', '', '')
  " Return path without expanded tilde, so it is easier to read.
  return fnamemodify(git_root_path, ':~')
endfunction

function! util#GetNodeJsRoot() abort
  let package_json_path = findfile('package.json', '.;' . $HOME . '/work')
  if empty(package_json_path)
    return 0
  endif
  " Expand to full path (:~) for better logs,
  " then get the directory (:h).
  return fnamemodify(package_json_path, ':~:h')
endfunction

function! util#error_msg(msg) abort
  echohl ErrorMsg
  echom a:msg
  echohl NONE
endfunction

function! util#prompt(msg) abort
  echohl Statement
  let ok = input(a:msg . ' ')
  echohl NONE
  " clear input
  normal! :<esc>
  if ok !=# 'y'
    echo 'skipped'
    return 0
  endif
  return 1
endfunction

function! util#input(msg, ...) abort
  let text = get(a:, 1, '')
  let user_input = input(a:msg . ': ', text)
  " clear input
  normal! :<esc>
  if empty(user_input)
    echo 'skipped'
    return
  endif
  return user_input
endfunction

" http://vim.1045645.n5.nabble.com/Add-milliseconds-to-strftime-td5724772.html
function! util#print_time(...) abort
  let text = get(a:, 1, 'time')
  execute "python3 text = '" . text . "'"
  python3 import datetime; print(text + ':', datetime.datetime.now().strftime("%H:%M:%S.%f")[:-3])
endfunction

" scriptease#capture
function! util#capture(excmd) abort
  try
    redir => out
    execute 'silent! ' . a:excmd
  finally
    redir END
  endtry
  return out
endfunction

function! util#messages() abort
  let messages = util#capture('messages')
  return reverse(filter(split(messages, '\n'), '!empty(v:val)'))
endfunction

function! util#EditFile(path)
  if bufnr(a:path) == -1
    silent execute 'tabnew ' . a:path
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      silent execute 'tabnew ' . a:path
    else
      call win_gotoid(wins[0])
    endif
  endif
endfunction

function! util#EditFileUpwards(filename)
  if filereadable(a:filename)
    " When exploring the root folder with Dirvish and
    " the file is at the root.
    " findfile() does not seem to work with Dirvish in that case.
    call util#EditFile(a:filename)
    return
  endif
  " Search from the directory of the current file upwards, until the home folder
  let path = findfile(a:filename, '.;' . $HOME)
  if !empty(path)
    call util#EditFile(path)
    return
  endif
  " Search from cwd upwards, until the home folder.
  " This might help in case the current file is outside of cwd (e.g. a Dropbox note).
  let path = findfile(a:filename, getcwd() . ';' . $HOME)
  if !empty(path)
    call util#EditFile(path)
    return
  endif
  echo 'File not found: ' . a:filename
endfunction

function! util#ToggleGlobalVar(varname) abort
  let value = get(g:, a:varname, 0)
  if value == 0
    let g:[a:varname] = 1
  else
    let g:[a:varname] = 0
  endif
  return get(g:, a:varname)
endfunction
