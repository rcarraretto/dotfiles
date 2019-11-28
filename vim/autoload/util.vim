function! util#GetGitRoot()
  " dir of current file (resolves symbolic links)
  let buf_dir = fnamemodify(resolve(expand('%:p')), ':h')
  if len(buf_dir) == 0
    " e.g. netrw
    return 0
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
