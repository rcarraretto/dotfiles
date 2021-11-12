" File system

function! fs#RefreshBuffer(path) abort
  try
    " 'noautocmd' avoids:
    " "E218: autocommand nesting too deep"
    " when calling fs#RefreshBuffer() from certain autocmds.
    " (more specifically, autocmd => :Log => fs#RefreshBuffer())
    "
    execute 'noautocmd silent checktime ' . a:path
  catch /E93\|E94\|E523/
    " E93: More than one match for /some/path/
    "
    " E94: No matching buffer for /some/path/
    " Could happen with Dirvish buffers (a:path is a directory),
    "
    " E523: May not be allowed, when executing code in the context of autocmd.
    " For example, running :Log inside of statusline#set().
  endtry
endfunction
