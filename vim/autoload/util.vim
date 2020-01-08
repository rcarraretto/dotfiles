function! util#GetGitRoot()
  " path of current file (resolves symbolic links)
  let buf_path = resolve(expand('%:p'))
  if isdirectory(buf_path)
    " dirvish
    let buf_dir = buf_path
  else
    " dir of current file
    let buf_dir = fnamemodify(buf_path, ':h')
    if len(buf_dir) == 0
      " e.g. netrw
      return 0
    endif
  endif
  let output = system('cd ' .  buf_dir . ' && git rev-parse --show-toplevel')
  if v:shell_error
    return 0
  endif
  " Remove null character (^@) from output
  " echom split(output, '\zs')
  " :h expr-[:]
  return output[:-2]
endfunction
