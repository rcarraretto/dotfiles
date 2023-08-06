function! util#GetGitRoot(...)
  " GetGitRoot()     => in relation to current buffer
  " GetGitRoot(path) => in relation to given path
  let opts = get(a:, 1, {})
  let path = get(opts, 'path', expand('%:p'))
  " Resolves symbolic links
  if get(opts, 'resolve_symlink', 1)
    let path = resolve(path)
  endif
  if isdirectory(path)
    " dirvish
    let dir = path
  else
    " dir of current file
    let dir = fnamemodify(path, ':h')
    if len(dir) == 0
      " e.g. netrw
      return 0
    endif
  endif
  let cmd = printf("cd '%s' && git rev-parse --show-toplevel", fnameescape(dir))
  let git_root_path = system(cmd)
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

function! util#error_msg(msg) abort
  echohl ErrorMsg
  let msg = substitute(a:msg, "\t", "  ", 'g')
  let lines = split(msg, "\n")
  for line in lines
    echom line
  endfor
  echohl NONE
endfunction

function! util#echo_exception() abort
  let exception_short = matchstr(v:exception, 'Vim([^)]\+):\zsE\d\+: \(.*\)')
  echohl ErrorMsg
  if empty(exception_short)
    echom v:exception
  else
    echom exception_short
  endif
  echohl NONE
endfunction

function! util#prompt(msg, ...) abort
  let opts = a:0 > 0 ? a:1 : {'type': 'danger'}
  if get(opts, 'type') == 'info'
    echohl Function
  elseif get(opts, 'type') == 'danger'
    echohl ErrorMsg
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
  if len(a:list) < 10
    for line in split(msg, "\n")
      echo line
    endfor
    " use getchar() to immediately collect the number,
    " without needing to press enter.
    let user_input = nr2char(getchar())
    " erase text that has been echoed so far
    redraw
  else
    let user_input = input(msg, '', 'custom,util#inputlist_complete')
  endif
  echohl none
  if empty(user_input) || user_input == "\r" || user_input == "\e"
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
" {'local': 0} (default) -> set
" {'local': 1}           -> setlocal
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
  let set_cmd = get(opts, 'local', 0) ? 'setlocal' : 'set'
  let set_expr = set_cmd . ' ' . a:option_name . "=" . new_value
  execute set_expr
  let updated_value = eval('&' . a:option_name)
  if get(opts, 'print') == 1
    echo set_expr
  endif
  return updated_value
endfunction

function! util#YankOperatorTarget(type) abort
  if a:type !=# 'v' && a:type !=# 'char'
    return [0, 'YankOperatorTarget: unsupported type: ' . a:type]
  endif
  " do not overwrite system clipboard
  let cb_save = &clipboard
  set clipboard-=unnamed
  let reg_save = @"
  if a:type ==# 'v'
    silent execute "normal! `<v`>y"
  elseif a:type ==# 'char'
    silent execute "normal! `[v`]y"
  endif
  let target = @"
  let @" = reg_save
  let &clipboard = cb_save
  if stridx(target, "\n") != -1
    return [0, 'YankOperatorTarget: cannot search multiline']
  endif
  return [target, 0]
endfunction

" Like matchlist() but return all matches
"
" Equivalent to javascript's String.prototype.match with the global flag 'g'
"
" "1 a 2 b 3".match(/(\d)/g)
" > (3) ["1", "2", "3"]
"
" echo util#MatchlistAll('1 2 3', '\(\d\)')
" ['1', '2', '3']
"
" https://vi.stackexchange.com/a/16491/24815
"
" _Note: It probably only works when you have 1 capture group
"
function! util#MatchlistAll(str, pat)
  let l:res = []
  call substitute(a:str, a:pat, '\=add(l:res, submatch(0))', 'g')
  return l:res
endfunction

function! util#GetDotfilesDirs() abort
  let dirs = map(split($DOTFILES_DIRS, ':'), 'fnameescape(v:val)')
  return join(dirs, ' ')
endfunction

" Workaround for vim-bookmarks plugin.
" 'util' namespace clash:
" https://github.com/MattesGroeger/vim-bookmarks/blob/9cc5fa7ecc23b052bd524d07c85356c64b92aeef/autoload/util.vim
if $USE_VIM_BOOKMARKS
  let vimbookmarks_path = $HOME . '/.vim/bundle/vim-bookmarks/autoload/util.vim'
  if filereadable(vimbookmarks_path)
    execute 'source ' . vimbookmarks_path
  endif
endif
