function! s:ToggleTestCase() abort
  let original_line = line('.')
  let test_case_line = search('^@test .\+ {$', 'b')
  let delta_line = original_line - test_case_line
  normal! ma
  if search('^\s*skip$', 'n') > 0
    " unskip all
    silent %g/^\s*skip$/d
    normal! `a
    echom "unskip"
  else
    " skip others (i.e., only)
    silent %s/^@test.*\n/\0  skip\r/g
    normal! `a
    +1delete
    normal! k
    echom "only"
  endif
  if delta_line > 0
    execute 'normal! ' . delta_line . 'j'
    normal! ^
  endif
  silent update
endfunction

function! bats#AddMappings() abort
  nnoremap <buffer> <leader>to :call <sid>ToggleTestCase()<cr>
endfunction
