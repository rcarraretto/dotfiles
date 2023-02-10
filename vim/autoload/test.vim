function! test#SetTestTarget(opts) abort
  let g:test_file_target = expand('%:p')
  call test#TestCurrentTarget(a:opts)
endfunction

function! test#TestCurrentTarget(opts) abort
  if !exists('g:test_file_target')
    let g:test_file_target = expand('%:p')
  endif
  let target = g:test_file_target
  if match(target, a:opts['test_file_regex']) == -1
    return util#error_msg('test#TestCurrentTarget: not a test file: ' . target)
  endif
  call test#ExecTest(target, a:opts)
endfunction

function! test#ExecTest(target, opts) abort
  let case_flag = ''
  if exists('g:test_case_target')
    let case_flag = printf(' --case=%s', g:test_case_target)
  endif
  if a:target == ''
    let core_cmd = a:opts['test_cmd']
  else
    let core_cmd = printf("%s --file=%s%s",
          \ a:opts['test_cmd'],
          \ a:target,
          \ case_flag
          \)
  endif
  call s:Dispatch(core_cmd, a:opts['parser'])
endfunction

function! test#Dispatch(cmd, parser) abort
  update
  call s:Dispatch(a:cmd, a:parser)
endfunction

function! s:Dispatch(cmd, parser) abort
  let test_cmd = printf("set -o pipefail; %s |& tovimqf --parser=%s --cwd=%s",
        \ a:cmd,
        \ a:parser,
        \ getcwd()
        \)
  execute printf('Dispatch -compiler=rc_compiler %s', test_cmd)
endfunction

function! test#AddTestMappings(opts) abort
  if !has_key(a:opts, 'test_cmd')
    return util#error_msg('test#AddTestMappings: opts is missing "test_cmd" key')
  endif
  if !has_key(a:opts, 'parser')
    return util#error_msg('test#AddTestMappings: opts is missing "parser" key')
  endif
  if !has_key(a:opts, 'test_file_regex')
    return util#error_msg('test#AddTestMappings: opts is missing "test_file_regex" key')
  endif
  execute 'nnoremap <buffer> <leader>st :update <bar> call test#SetTestTarget(' . string(a:opts) . ')<cr>'
  execute 'nnoremap <buffer> <space>t :update <bar> call test#TestCurrentTarget(' . string(a:opts) . ')<cr>'
  execute 'nnoremap <buffer> <space>T :update <bar> call test#ExecTest('''', ' . string(a:opts) . ')<cr>'
  if has_key(a:opts, 'toggle_only_test_case_f')
    execute 'nnoremap <buffer> <leader>to :call test#ToggleOnlyTestCase('
          \ . string(a:opts['toggle_only_test_case_f']) . ', '
          \ . string(a:opts['test_file_regex'])
          \ ')<cr>'
  endif
  if has_key(a:opts, 'reset_only_test_case_f')
    execute 'nnoremap <buffer> <leader>tr :call test#ResetOnlyTestCase('
          \ . string(a:opts['reset_only_test_case_f']) . ', '
          \ . string(a:opts['test_file_regex'])
          \ ')<cr>'
  endif
endfunction

function! test#ToggleOnlyTestCase(f, regex) abort
  let path = expand('%:p')
  if match(path, a:regex) == -1
    return util#error_msg('test#ToggleOnlyTestCase: not a test file: ' . path)
  endif
  call function(a:f)()
endfunction

function! test#ResetOnlyTestCase(f, regex) abort
  let path = expand('%:p')
  if match(path, a:regex) == -1
    return util#error_msg('test#ResetOnlyTestCase: not a test file: ' . path)
  endif
  call function(a:f)()
endfunction

function! test#AddTestMappingsGolang() abort
  call test#AddTestMappings({
        \'test_file_regex': '_test\.go$',
        \'toggle_only_test_case_f': 'test#GolangToggleOnlyTestCase',
        \'reset_only_test_case_f': 'test#GolangResetOnlyTestCase',
        \'parser': 'go-test',
        \'test_cmd': 'run-golang-test-vim',
        \})
endfunction

function! test#GolangToggleOnlyTestCase() abort
  let save_pos = getpos('.')
  " account for being exactly on the line of func definition
  normal! $
  let pat = '^func \zsTest[[:alnum:]_]\+'
  let line_num = search(pat, 'bn')
  if line_num == 0
    call setpos('.', save_pos)
    return util#error_msg('test#GolangToggleOnlyTestCase: test case not found')
  endif
  let line = getline(line_num)
  let matches = matchlist(line, pat)
  if len(matches) == 0
    call setpos('.', save_pos)
    return util#error_msg('test#GolangToggleOnlyTestCase: Could not match line: ' . line)
  endif
  let test_case = matches[0]
  if get(g:, 'test_case_target', '') == test_case
    unlet! g:test_case_target
    echom "unlet g:test_case_target"
  else
    let g:test_case_target = test_case
    echom printf("g:test_case_target = %s", g:test_case_target)
  endif
  call setpos('.', save_pos)
endfunction

function! test#GolangResetOnlyTestCase() abort
  unlet! g:test_case_target
  echom "unlet g:test_case_target"
endfunction
