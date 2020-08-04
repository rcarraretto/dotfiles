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

function! util#prompt(msg, ...) abort
  let opts = a:0 > 0 ? a:1 : {'type': 'danger'}
  if get(opts, 'type') == 'info'
    echohl Function
  else
    echohl Statement
  endif
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

function! util#inputlist_complete(arg_lead, cmd_line, cursor_pos) abort
  return join(s:inputlist, "\n")
endfunction

function! util#inputlist(list, ...) abort
  let opts = a:0 > 0 ? a:1 : {}
  let msg = join(map(copy(a:list), "(v:key + 1) . '. ' . v:val"), "\n") . "\nSelect number: "
  if !empty(get(opts, 'intro'))
    let msg = get(opts, 'intro') . "\n" . msg
  endif
  let s:inputlist = a:list
  echohl String
  let user_input = input(msg, '', 'custom,util#inputlist_complete')
  echohl none
  " Clear input.
  " Else 'skipped' echos would print on the same line as user input.
  echo ' '
  if empty(user_input)
    echo 'skipped'
    return
  endif
  if user_input !~ '^\d\+$'
    if index(a:list, user_input) >= 0
      " The previous 'echo' will cause 'Press ENTER or type command to continue'.
      " Press enter to skip that message.
      call feedkeys("\<CR>")
      return user_input
    endif
    echo 'skipped (invalid number)'
    return
  endif
  let index = str2nr(user_input)
  if index <= 0 || index > len(a:list)
    echo 'skipped (out of bounds)'
    return
  endif
  " The previous 'echo' will cause 'Press ENTER or type command to continue'.
  " Press enter to skip that message.
  call feedkeys("\<CR>")
  return a:list[index - 1]
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

function! s:GetOpenCmdFromCount() abort
  if v:count == 1 || v:count == 6
    return 'new'
  elseif v:count == 2 || v:count == 7
    return 'vnew'
  endif
  return 'tabnew'
endfunction

function! util#EditFile(path)
  let opencmd = s:GetOpenCmdFromCount()
  if bufnr(a:path) == -1
    silent execute opencmd . ' ' . a:path
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      silent execute opencmd . ' ' . a:path
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

function! util#ToggleGlobalVar(varname, ...) abort
  let value = get(g:, a:varname, 0)
  if value == 0
    let g:[a:varname] = 1
  else
    let g:[a:varname] = 0
  endif
  let print = get(a:, 1)
  if print
    echo "g:" . a:varname . "=" . get(g:, a:varname)
  endif
  return get(g:, a:varname)
endfunction

function! util#ToggleBufVar(varname, ...) abort
  let value = get(b:, a:varname, 0)
  if value == 0
    let b:[a:varname] = 1
  else
    let b:[a:varname] = 0
  endif
  let print = get(a:, 1)
  if print
    echo "b:" . a:varname . "=" . get(b:, a:varname)
  endif
  return get(b:, a:varname)
endfunction
