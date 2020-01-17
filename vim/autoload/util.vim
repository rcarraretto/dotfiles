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
  let git_root_path = system('cd ' . dir . ' && git rev-parse --show-toplevel')
  if v:shell_error
    return 0
  endif
  " Return path without expanded tilde, so it is easier to read.
  return fnamemodify(git_root_path, ':~')
endfunction

function! util#error_msg(msg) abort
  echohl ErrorMsg
  echom a:msg
  echohl NONE
endfunction
