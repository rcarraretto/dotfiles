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

function! util#delayed_echo_callback(timer_id) abort
  echo s:delayed_echo_msg
endfunction

function! util#delayed_echo(msg) abort
  let s:delayed_echo_msg = a:msg
  call timer_start(0, 'util#delayed_echo_callback')
endfunction

" Based on vim's inputlist()
" and
" Quramy/tsuquyomi :TsuImport
" https://github.com/Quramy/tsuquyomi/blob/85fffd5939c8fc5750b35a937b965af2ad5b0b15/autoload/tsuquyomi/es6import.vim#L415
" ~/.vim/bundle/tsuquyomi/autoload/tsuquyomi/es6import.vim:410:46
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
  if empty(user_input)
    " User pressed <cr> or <esc>.
    "
    " Delayed echo is used to avoid:
    " - Having the message on the same line as user input
    " - Seeing the message 'Press ENTER or type command to continue'
    "
    " This is not perfect, as an error may be printed in-between and then
    " shadowed by this message.
    call util#delayed_echo('skipped')
    return
  endif
  if user_input !~ '^\d\+$'
    if index(a:list, user_input) >= 0
      return user_input
    endif
    call util#delayed_echo('skipped (invalid number)')
    return
  endif
  let index = str2nr(user_input)
  if index <= 0 || index > len(a:list)
    call util#delayed_echo('skipped (out of bounds)')
    return
  endif
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

function! util#EditFile(path) abort
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

function! util#EditFileUpwards(filename) abort
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

" Open/close window, depending on whether the file is opened in the current tab.
function! util#ToggleWindowInTab(path, ...) abort
  let wincmd = get(a:, 1, 'vsplit')
  let opencmd = "silent " . wincmd . " " . a:path
  if bufnr(a:path) == -1
    " If no buffer (across all tabs), open file
    " (new buffer and window)
    execute opencmd
    return 1
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      " If buffer exists, but no corresponding window (across all tabs), open file
      execute opencmd
      return 1
    else
      for win in wins
        if getwininfo(win)[0]['tabnr'] == tabpagenr()
          " If already opened in tab, close file
          call win_gotoid(win)
          wincmd c
          return 0
        endif
      endfor
      " If not already opened in tab, open file
      execute opencmd
      return 1
    endif
  endif
endfunction

function! util#CloseWindowInTab(path) abort
  if bufnr(a:path) == -1
    return 0
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      return 0
    else
      for win in wins
        if getwininfo(win)[0]['tabnr'] == tabpagenr()
          call win_gotoid(win)
          wincmd c
          return 1
        endif
      endfor
      return 0
    endif
  endif
endfunction

function! util#ToggleGlobalVar(varname, ...) abort
  let opts = get(a:, 1, {})
  let value = get(g:, a:varname, 0)
  if value == 0
    let new_value = get(opts, 'on_value', 1)
  else
    let new_value = 0
  endif
  let g:[a:varname] = new_value
  let updated_value = get(g:, a:varname)
  if get(opts, 'print') == 1
    echo "g:" . a:varname . "=" . updated_value
  endif
  return updated_value
endfunction

function! util#ToggleBufVar(varname, ...) abort
  let opts = get(a:, 1, {})
  let value = getbufvar('', a:varname, 0)
  let off_value = get(opts, 'off_value', 0)
  let on_value = get(opts, 'on_value', 1)
  if value == off_value
    let new_value = on_value
  else
    let new_value = off_value
  endif
  call setbufvar('', a:varname, new_value)
  let updated_value = getbufvar('', a:varname)
  if get(opts, 'print') == 1
    if a:varname[0] == '&'
      echo "setlocal " . a:varname . "=" . updated_value
    else
      echo "b:" . a:varname . "=" . updated_value
    endif
  endif
  return updated_value
endfunction
