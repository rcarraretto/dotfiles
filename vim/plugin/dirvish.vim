if $USE_NETRW
  finish
endif

" sort: folders first
let g:dirvish_mode = ':sort ,^.*[\/],'

function! s:DirvishConfig()
  setlocal nonumber
  setlocal norelativenumber
  call s:DirvishMappings()
endfunction

function! s:DirvishMappings()
  let mapping = maparg("<cr>", "n", 0, 1)
  if empty(mapping) || !mapping['buffer']
    " if there is no nmap <buffer> <cr>,
    " then this function was already executed
    return
  endif
  " keep <cr> as it normally is (nnoremap <cr> :)
  nunmap <buffer> <cr>
  " map 'o' to what <cr> is in dirvish (open file)
  nnoremap <buffer> <silent> o :<c-u>call dirvish#open("edit", 0)<cr>
  " map 's' to what 'o' is in dirvish (open file in a horizontal split)
  nnoremap <buffer> <silent> s :<c-u>call dirvish#open("split", 1)<cr>
  " rename
  nnoremap <buffer> <silent> R :<c-u>call <sid>DirvishRename()<cr>
  " mkdir
  " - add <nowait> because of 'ds' (Dsurround from surround.vim)
  " - https://vi.stackexchange.com/a/2774
  nnoremap <buffer> <silent> <nowait> d :<c-u>call <sid>DirvishMkdir()<cr>
  " rm
  nnoremap <buffer> <silent> <nowait> D :<c-u>call <sid>DirvishRm()<cr>
  " implode
  nnoremap <buffer> <silent> I :<c-u>call <sid>DirvishImplode()<cr>
  " mv
  nnoremap <buffer> <silent> mv :<c-u>call <sid>DirvishMv(0)<cr>
  " cp
  nnoremap <buffer> <silent> cp :<c-u>call <sid>DirvishMv(1)<cr>
  " opendiff
  command! -buffer DirvishOpenDiff :call <sid>DirvishOpenDiff()
endfunction

function! s:DirvishRefresh() abort
  edit
  try
    " restore cursor position
    " :h `"
    execute "normal! g`\""
  catch /E19/
    " E19: Mark has invalid line number
    " Line is gone. Ignore it.
    " This happens e.g. when deleting the last file of the list.
  endtry
endfunction

function! s:DirvishRename() abort
  let path = getline('.')
  let new_path = input('Moving ' . path . ' to: ', path, 'file')
  call rename(path, new_path)
  call s:DirvishRefresh()
endfunction

function! s:DirvishMkdir() abort
  let dirname = input('Mkdir: ')
  if !len(dirname)
    return
  endif
  let new_path = @% . dirname
  call mkdir(new_path)
  call s:DirvishRefresh()
endfunction

function! s:DirvishRm() abort
  let path = getline('.')
  let ok = util#prompt('Remove ' . path . '?')
  if !ok
    return
  endif
  if isdirectory(path)
    let rm_cmd = printf("rm -r '%s'", fnameescape(path))
    let output = system(rm_cmd)
    if v:shell_error
      echohl Error
      echom 'DirvishRm: Error: ' . output
      echohl NONE
    endif
  elseif filereadable(path)
    call delete(path)
  else
    echohl Error
    echom 'File does not exist'
    echohl NONE
    return
  endif
  call s:DirvishRefresh()
endfunction

" Move contents of folder to parent folder
function s:DirvishImplode() abort
  let path = getline('.')
  if !isdirectory(path)
    return util#error_msg('DirvishImplode: not a directory: ' . path)
  endif
  let dirname = fnamemodify(path[:-2], ':t')
  let ok = util#prompt("Implode directory '" . dirname . "'?")
  if !ok
    return
  endif
  let cmd = 'mv ' . fnameescape(path) . '* ' . fnameescape(@%) . ' && rmdir ' . fnameescape(path)
  let output = system(cmd)
  if v:shell_error
    echohl Error
    echom 'DirvishImplode: Error: ' . output
    echohl NONE
  endif
  call s:DirvishRefresh()
endfunction

function! s:ArgList() abort
  let i = 0
  let l = []
  while i < argc()
    call add(l, argv(i))
    let i = i + 1
  endwhile
  return l
endfunction

function! s:dirvish_path_shortname(path)
  if isdirectory(a:path)
    return "'" . fnamemodify(a:path[:-2], ':t') . "'"
  endif
  return "'" . fnamemodify(a:path, ':t') . "'"
endfunction

function! s:DirvishMv(copy) abort
  let dirpath = getline('.')
  if !isdirectory(dirpath)
    let dirpath = fnamemodify(dirpath, ':h') . '/'
    if !isdirectory(dirpath)
      return util#error_msg('DirvishMv: target is not a directory: ' . dirpath)
    endif
  endif
  let cwd = getcwd() . '/'
  let filepaths = filter(s:ArgList(), 'filereadable(v:val) || (isdirectory(v:val) && v:val != cwd)')
  if len(filepaths) < 1
    return util#error_msg("DirvishMv: no file has been selected (use 'x' to select a file)")
  endif
  let filenames = map(copy(filepaths), 's:dirvish_path_shortname(v:val)')
  let dirname = s:dirvish_path_shortname(dirpath)
  if a:copy
    let action_name = 'Copy'
    let program = 'gcp -R'
  else
    let action_name = 'Move'
    let program = 'mv'
  endif
  let prompt_msg = printf('%s %s to directory %s? ', action_name, join(filenames, ', '), dirname)
  if !util#prompt(prompt_msg)
    return
  endif
  let cmd = printf('%s %s %s',
        \ program,
        \ join(map(filepaths, 'fnameescape(v:val)'), ' '),
        \ fnameescape(dirpath)
        \)
  let output = system(cmd)
  if v:shell_error
    call util#error_msg('DirvishMv: Error: ' . output)
  endif
  argdelete *
  execute "Dirvish " . dirpath
endfunction

function! s:DirvishOpenDiff() abort
  let filepaths = filter(s:ArgList(), 'filereadable(v:val)')
  if len(filepaths) < 1
    return util#error_msg("DirvishOpenDiff: no file has been selected (use 'x' to select a file)")
  endif
  if len(filepaths) == 1
    return util#error_msg("DirvishOpenDiff: only one file has been selected")
  endif
  let filenames = map(copy(filepaths), 's:dirvish_path_shortname(v:val)')
  if !util#prompt("Diff " . join(filenames, ', ') . "? ", {'type': 'info'})
    return
  endif
  let cmd = 'opendiff ' . join(map(filepaths, 'fnameescape(v:val)'), ' ')
  let output = system(cmd)
  if v:shell_error
    return util#error_msg('DirvishOpenDiff: Error: ' . output)
  endif
endfunction

augroup DirvishConfig
  autocmd!
  autocmd FileType dirvish call s:DirvishConfig()
  " Remove arguments from arglist.
  "
  " The arglist can be used by dirvish to select files,
  " so I prefer to start vim with an emtpy list.
  "
  " On startup, the arglist is populated with the path arguments.
  " So when starting vim with `vim .`, it's populated with the path
  " of the current directory.
  autocmd VimEnter * if argc() > 0 | argdelete * | endif
augroup END
