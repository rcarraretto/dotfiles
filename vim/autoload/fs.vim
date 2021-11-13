" File system

" Adapted from:
" https://github.com/vim-scripts/Rename
function! fs#RenameFile(name)
  let oldfile = expand('%:p')
  let newfile = fnamemodify(a:name, ':p')
  if oldfile == newfile
    return util#error_msg('RenameFile: renaming to the same file')
  endif
  if bufexists(newfile)
    return util#error_msg('RenameFile: A buffer with that name already exists')
  endif

  let v:errmsg = ''
  silent! execute 'saveas ' . a:name
  if v:errmsg !~# '^$\|^E329'
    echoerr v:errmsg
    return
  endif

  if expand('%:p') == oldfile || !filewritable(expand('%:p'))
    return util#error_msg('RenameFile: Rename failed for some reason')
  endif

  let lastbufnr = bufnr('$')
  if fnamemodify(bufname(lastbufnr), ':p') == oldfile
    silent execute lastbufnr . 'bwipe!'
  else
    return util#error_msg('RenameFile: Could not wipe out the old buffer for some reason')
  endif

  if delete(oldfile) != 0
    return util#error_msg('RenameFile: Could not delete the old file: ' . oldfile)
  endif
endfunction

" Based on eunuch.vim :Delete
function! fs#DeleteCurrentFile() abort
  let absolute_path = expand('%:p')
  if empty(absolute_path)
    " e.g. :new
    return util#error_msg('DeleteCurrentFile: Buffer does not have a path')
  endif
  if isdirectory(absolute_path)
    " e.g. dirvish buffer
    return util#error_msg('DeleteCurrentFile: Buffer cannot be a directory')
  endif
  if !filereadable(absolute_path)
    " e.g.
    " :new path/to/file
    " :Remove
    return util#error_msg('DeleteCurrentFile: Buffer is not associated to a file in disk')
  endif
  " Use bwipeout instead of bdelete.
  " This way, another file can be renamed to have the name of the deleted file.
  " Else s:RenameFile() causes 'A buffer with that name already exists'.
  bwipeout
  if delete(absolute_path)
    return util#error_msg('DeleteCurrentFile: Failed to delete "' . absolute_path . '"')
  endif
endfunction

" Vim sends a warning when a file was initially opened, but then deleted
" outside of vim. This happpens, e.g., when switching git branches while
" having many buffers open.
"
" Add a hack to disable this behavior.
" https://stackoverflow.com/a/52781365/2277505
"
" Adapted from:
" https://vim.fandom.com/wiki/File_no_longer_available_-_mark_buffer_modified
function fs#FileChangedShell(name)
  let msg = 'File "'.a:name.'"'
  let v:fcs_choice = ''
  if v:fcs_reason == "deleted"
    " Set the buffer as 'readonly', instead of displaying E211.
    " By doing this, we can prevent the file from being accidentally saved in vim
    " and thus inadvertently put back into the file system.
    call setbufvar(expand(a:name), '&readonly', '1')
    " Set the buffer as 'modified', so if we quit vim,
    " we're aware that changes will be lost, if we don't save it.
    call setbufvar(expand(a:name), '&modified', '1')
  elseif v:fcs_reason == "time"
    let msg .= " timestamp changed"
  elseif v:fcs_reason == "mode"
    let msg .= " permissions changed"
  elseif v:fcs_reason == "changed"
    let msg .= " contents changed"
    let v:fcs_choice = "ask"
  elseif v:fcs_reason == "conflict"
    let msg .= " CONFLICT --"
    let msg .= " is modified, but"
    let msg .= " was changed outside Vim"
    let v:fcs_choice = "ask"
    echohl ErrorMsg
  else  " unknown values (future Vim versions?)
    let msg .= " FileChangedShell reason="
    let msg .= v:fcs_reason
    let v:fcs_choice = "ask"
    echohl ErrorMsg
  endif
  redraw!
  echomsg msg
  echohl None
endfunction

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

function! fs#OpenFolderInFinder() abort
  let dir = expand('%:p:h')
  if !isdirectory(dir)
    return util#error_msg('OpenFolderInFinder: not a folder: ' . dir)
  endif
  echom "OpenFolderInFinder: " . dir
  call system("open -a Finder " . fnameescape(dir))
endfunction

function! fs#SysOpen(filename)
  let filename = a:filename
  if empty(a:filename)
    if &ft == 'dirvish'
      let filename = fnameescape(getline('.'))
    else
      let filename = expand('%')
    endif
  endif
  if isdirectory(filename)
    return util#error_msg('SysOpen: selected path cannot be a directory')
  endif
  let ext = fnamemodify(filename, ':e')
  if index(['sh'], ext) != -1
    echo 'SysOpen: unsupported extension: ' . ext
    return
  endif
  let output = system('open ' . filename)
  if v:shell_error
    echo 'Error: ' . substitute(output, '\n', ' ', 'g')
    return
  endif
endfunction

function! fs#OpenInSourceTree()
  let output = util#GetGitRoot()
  if empty(output)
    echohl ErrorMsg
    echom "OpenInSourceTree: couldn't find git root"
    echohl NONE
    return
  endif
  call system('open -a SourceTree ' . fnameescape(output))
endfunction