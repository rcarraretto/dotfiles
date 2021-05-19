function! util#GetGitRoot(...)
  " GetGitRoot()     => in relation to current buffer
  " GetGitRoot(path) => in relation to given path
  let opts = get(a:, 1, {})
  let path = get(opts, 'path', expand('%:p'))
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
  if get(opts, 'full_path', 0)
    return fnamemodify(git_root_path, ':p')[:-2]
  endif
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
  let msg = substitute(a:msg, "\t", "  ", 'g')
  let lines = split(msg, "\n")
  for line in lines
    echom line
  endfor
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
  elseif v:count == 3 || v:count == 8
    return 'edit'
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

function! util#OpenWindowInTab(path, ...) abort
  let wincmd = get(a:, 1, 'vsplit')
  let opencmd = "silent " . wincmd . " " . a:path
  if bufnr(a:path) == -1
    " There is no buffer with this path.
    " Open the file.
    silent execute opencmd
    return 1
  endif

  let wins = getbufinfo(a:path)[0]['windows']
  if empty(wins)
    " Somehow there are no windows with this file open.
    " Open the file.
    silent execute opencmd
    return 2
  endif

  for win in wins
    if getwininfo(win)[0]['tabnr'] == tabpagenr()
      " Found window in the current tab.
      " Go to it.
      call win_gotoid(win)
      return 3
    endif
  endfor

  " File is probably opened in a different tab.
  " Create a new window in the current tab.
  silent execute opencmd
  return 4
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

" Example:
" :call util#ToggleOption('cursorlineopt', {'print': 1, 'off_value': 'number', 'on_value': 'both'})
function! util#ToggleOption(option_name, ...) abort
  let opts = get(a:, 1, {})
  let value = eval('&' . a:option_name)
  let off_value = get(opts, 'off_value', 0)
  let on_value = get(opts, 'on_value', 1)
  if value == off_value
    let new_value = on_value
  else
    let new_value = off_value
  endif
  let update_cmd = "set " . a:option_name . "=" . new_value
  execute update_cmd
  let updated_value = eval('&' . a:option_name)
  if get(opts, 'print') == 1
    echo update_cmd
  endif
  return updated_value
endfunction

function! util#SetTestTarget(opts) abort
  let g:test_file_target = expand('%:p')
  call util#TestCurrentTarget(a:opts)
endfunction

function! util#TestCurrentTarget(opts) abort
  let target = get(g:, 'test_file_target', expand('%:p'))
  if match(target, a:opts['test_file_regex']) == -1
    return util#error_msg('util#TestCurrentTarget: not a test file: ' . target)
  endif
  call util#ExecTest(target, a:opts)
endfunction

function! util#ExecTest(target, opts) abort
  let case_flag = ''
  if exists('g:test_case_target')
    let case_flag = printf(' --case=%s', g:test_case_target)
  endif
  let test_cmd = printf("%s --file=%s%s |& %s --cwd=%s",
        \ a:opts['test_cmd'],
        \ a:target,
        \ case_flag,
        \ a:opts['parser'],
        \ getcwd()
        \)
  execute printf('Dispatch -compiler=rc_compiler %s', test_cmd)
endfunction

function! util#AddTestMappings(opts) abort
  if !has_key(a:opts, 'test_cmd')
    return util#error_msg('util#AddTestMappings: opts is missing "test_cmd" key')
  endif
  if !has_key(a:opts, 'parser')
    return util#error_msg('util#AddTestMappings: opts is missing "parser" key')
  endif
  if !has_key(a:opts, 'test_file_regex')
    return util#error_msg('util#AddTestMappings: opts is missing "test_file_regex" key')
  endif
  execute 'nnoremap <buffer> <leader>st :update <bar> call util#SetTestTarget(' . string(a:opts) . ')<cr>'
  execute 'nnoremap <buffer> <space>t :update <bar> call util#TestCurrentTarget(' . string(a:opts) . ')<cr>'
  if has_key(a:opts, 'toggle_only_test_case_f')
    execute 'nnoremap <buffer> <leader>to :call util#ToggleOnlyTestCase('
          \ . string(a:opts['toggle_only_test_case_f']) . ', '
          \ . string(a:opts['test_file_regex'])
          \ ')<cr>'
  endif
endfunction

function! util#ToggleOnlyTestCase(f, regex) abort
  let path = expand('%:p')
  if match(path, a:regex) == -1
    return util#error_msg('util#ToggleOnlyTestCase: not a test file: ' . path)
  endif
  call function(a:f)()
endfunction

function! util#GolangToggleOnlyTestCase() abort
  let save_pos = getpos('.')
  " account for being exactly on the line of func definition
  normal! $
  let pat = '^func \zsTest[[:alnum:]_]\+'
  let line_num = search(pat, 'bn')
  if line_num == 0
    call setpos('.', save_pos)
    return util#error_msg('util#GolangToggleOnlyTestCase: test case not found')
  endif
  let line = getline(line_num)
  let matches = matchlist(line, pat)
  if len(matches) == 0
    call setpos('.', save_pos)
    return util#error_msg('util#GolangToggleOnlyTestCase: Could not match line: ' . line)
  endif
  let test_case = matches[0]
  if get(g:, 'test_case_target', '') == test_case
    unlet! g:test_case_target
    echom "unlet g:test_case_target"
  else
    let g:test_case_target = test_case
    echom printf("g:test_case_target = %s", g:test_case_target)
  endif
  call setpos('.', save_pos)
endfunction
