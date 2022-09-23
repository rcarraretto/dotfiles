function! s:ToggleTestCase() abort
  let original_line = line('.')
  let test_case_line = search('^@test .\+ {$', 'b')
  let delta_line = original_line - test_case_line
  normal! ma
  if match(getline(line('.') + 1), '^\s*skip') != -1
    " current test is skipped.
    " unskip all first, so we land on (b)
    silent %g/^\s*skip$/d
    let delta_line -= 1
  endif
  if search('^\s*skip$', 'n') > 0
    " (a) unskip all
    silent %g/^\s*skip$/d
    normal! `a
    echom "unskip"
  else
    " (b) skip others (i.e., only)
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
