function! mapping#VimscriptMappings() abort
  nnoremap <buffer> <leader>ss :silent update <bar> call vimutil#DisarmPluginGuard() <bar> source %<cr>
endfunction

function! mapping#JavascriptMappings() abort
  nnoremap <buffer> <leader>cl :call proglang#javascript#JavascriptLogVariable('cl')<cr>
  nnoremap <buffer> <leader>co :call proglang#javascript#JavascriptLogVariable('co')<cr>
  nnoremap <buffer> <leader>tv :call proglang#ToggleVariable()<cr>
  call mochajs#AddMappings()
endfunction

function! mapping#TypescriptMappings() abort
  nnoremap <leader>re :call proglang#javascript#TypescriptReload()<cr>
endfunction

function! mapping#GolangMappings() abort
  nnoremap <buffer> <silent> K :call proglang#golang#GoDocToggle()<cr>
endfunction

function! mapping#TerraformMappings() abort
  nnoremap <buffer> <space>/r :call proglang#terraform#SearchResource()<cr>
endfunction

function! mapping#PEMMappings() abort
  nnoremap <buffer> K :call proglang#pem#ShowCertInfo()<cr>
endfunction

function! mapping#FugitiveMappings()
  if !exists('b:fugitive_type')
    return
  endif
  if exists('b:mapping_fugitive_cr')
    return
  endif
  let mapping = maparg("<cr>", "n", 0, 1)
  if empty(mapping) || !mapping['buffer']
    return
  endif
  " e.g. ':<C-U>exe <SID>BlameCommit("exe ''norm q''<Bar>edit")<CR>
  let b:mapping_fugitive_cr = substitute(maparg("<cr>", "n"), "|", "<bar>", 'g')
  " map 'o' to what <cr> is in fugitive (open file in existing window)
  execute "nnoremap <buffer> <silent> o " . b:mapping_fugitive_cr
  " unmap <cr> for fugitive buffer,
  " which will make <cr> fallback to global behavior, i.e.,
  " nnoremap <cr> :
  nunmap <buffer> <cr>
endfunction

function! mapping#AgitMappings()
  let mapping = maparg("<cr>", "n", 0, 1)
  if empty(mapping) || !mapping['buffer']
    " if there is no nmap <buffer> <cr>,
    " then this function was already executed
    return
  endif
  " keep <cr> as it normally is (nnoremap <cr> :)
  nunmap <buffer> <cr>
  " map 'o' to what <cr> is in Agit (open commit)
  nnoremap <buffer> o <Plug>(agit-show-commit)
endfunction
