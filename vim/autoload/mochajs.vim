" Mappings to toggle mocha/jest test cases

function! s:ToggleTestCase(scope) abort
  let target_scope = '.' . a:scope
  let save_pos = getpos('.')

  " account for 'describe' on beginning of line
  normal! $

  let testFuncRegex = '\(^\(\s*\)\(it\|describe\|test\|xtest\)\)\(\.only\|\.skip\)\?\ze('
  call search(testFuncRegex, 'b')
  let matches = matchlist(getline('.'), testFuncRegex)

  if !empty(matches)
    " it | describe | test | xtest
    let type = matches[3]
    " .only | .skip
    let scope = matches[4]

    if type == 'xtest'
      if target_scope == '.skip'
        " xtest => test
        let sline = substitute(getline('.'), testFuncRegex, '\2test', '')
      else
        " xtest => test.only
        let sline = substitute(getline('.'), testFuncRegex, '\2test' . target_scope, '')
      endif
    elseif empty(scope) || scope != target_scope
      " it => it.only
      " it => it.skip
      " test => test.skip
      " test => test.only
      " it.only => it.skip
      " it.skip => it.only
      " test.only => test.skip
      " test.skip => test.only
      let sline = substitute(getline('.'), testFuncRegex, '\1' . target_scope, '')
    else
      " it.only => it
      " it.skip => it
      " test.only => test
      " test.skip => test
      let sline = substitute(getline('.'), testFuncRegex, '\1', '')
    endif

    call setline('.', sline)
    silent! write

    echo substitute(sline, '^\s*', '', '')
  endif

  call setpos('.', save_pos)
endfunction

function! s:ToggleTestDescribe(scope) abort
  let save_pos = getpos('.')

  " account for 'describe' on beginning of line
  normal! $

  let pat = '\(^\s*describe\)\(\.only\|\.skip\|(\)'
  let pathMethod = 'describe\.\(only\|skip\)'
  call search(pat, 'b')
  if match(getline('.'), pathMethod) == -1
    " describe => describe.only
    let sline = substitute(getline('.'), pat, '\1.' . a:scope . '(', '')
  else
    " describe.only => describe
    let sline = substitute(getline('.'), pat, '\1', '')
  endif
  call setline('.', sline)
  echo substitute(sline, '^\s*', '', '')

  call setpos('.', save_pos)
  silent! write
endfunction

function! s:ResetOnlys() abort
  let save_pos = getpos('.')
  %s/^\s*\zs\(describe\|it\|test\)\.only\ze(/\1/e
  call setpos('.', save_pos)
  silent! write
endfunction

function! s:ResetOnlysAndSkips() abort
  let save_pos = getpos('.')
  %s/^\s*\zs\(describe\|it\|test\)\.only\ze(/\1/e
  %s/^\s*\zs\(describe\|it\|test\)\.skip\ze(/\1/e
  %s/^\s*\zsxtest(/test(/e
  call setpos('.', save_pos)
  silent! write
endfunction

" After running a test and having the error message on the qf list,
" attempts to insert update the assertion.
" Limitations:
" - does not support multiline
" - does not support jest
function! s:FixTestAssertion() abort
  if len(getqflist()) == 0
    echohl ErrorMsg
    echom 'FixTestAssertion: quickfix list is empty'
    echohl NONE
    return
  endif
  let qf_text = getqflist()[0].text
  " AssertionError: expected 'batata' to equal 'arroz'
  let ae_matches = matchlist(qf_text, 'expected \(.*\) to equal \(.*\)')
  if len(ae_matches) == 0
    echohl ErrorMsg
    echom 'FixTestAssertion: could not parse assertion error'
    echohl NONE
    return
  endif
  let new_assertion = ae_matches[1]
  " expect(result).to.equal('arroz');
  let new_text = substitute(getline('.'), 'expect(\(.*\))\.to\.equal(\(.*\))', 'expect(\1).to.equal(' . new_assertion . ')', '')
  call setline('.', new_text)
  silent! write
endfunction

function! mochajs#AddMappings() abort
  nnoremap <buffer> <leader>to :call <sid>ToggleTestCase('only')<cr>
  nnoremap <buffer> <leader>tdo :call <sid>ToggleTestDescribe('only')<cr>
  nnoremap <buffer> <leader>tO :call <sid>ResetOnlysAndSkips() <bar> call <sid>ToggleTestCase('only')<cr>
  nnoremap <buffer> <leader>tk :call <sid>ToggleTestCase('skip')<cr>
  nnoremap <buffer> <leader>tr :call <sid>ResetOnlys()<cr>
  nnoremap <buffer> <leader>tR :call <sid>ResetOnlysAndSkips()<cr>
  nnoremap <buffer> <leader>tfa :call <sid>FixTestAssertion()<cr>
  nnoremap <buffer> <space>/t /^\s*\zs\(describe\<bar>it\<bar>test\)\(\.only\<bar>\.skip\<bar>(\)<cr>
endfunction
