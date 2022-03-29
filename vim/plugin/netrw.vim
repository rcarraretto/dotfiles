if !$USE_NETRW
  " cancel netrw altogether
  let g:loaded_netrwPlugin = 1
  finish
endif

let g:netrw_list_hide = '.*\.DS_Store$,.*\.pyc$'
let g:netrw_banner = 0
" when previewing files with 'p', split vertically
let g:netrw_preview = 1

function! s:NetrwMappings()
  " note:
  " 'echom' might not work within this function
  " https://vi.stackexchange.com/a/8380

  " store original netrw mappings
  if !exists('s:mapping_netrw_cr')
    let s:mapping_netrw_cr = maparg("<cr>", "n")
    let s:mapping_netrw_o = maparg("o", "n")
  endif

  " Cancel netrw default <cr> mapping that will open the file in a new window
  " so <cr> is still : (nnoremap <cr> :)
  let s:mapping_current_cr = maparg("<cr>", "n", 0, 1)
  if !empty(s:mapping_current_cr) && s:mapping_current_cr['buffer']
    nunmap <buffer> <cr>
  endif

  " map 'o' to what <cr> is in netrw (open file in a new window)
  execute "nnoremap <buffer> <silent> o " . s:mapping_netrw_cr

  " map 'x' to what 'o' is in netrw (open file in a horizontal split)
  execute "nnoremap <buffer> <silent> x " . s:mapping_netrw_o
endfunction

augroup NetrwConfig
  autocmd!
  autocmd FileType netrw call s:NetrwMappings()
augroup END
