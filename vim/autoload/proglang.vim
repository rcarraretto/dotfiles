" Similar to :%!cmd (:h :range!)
" but do not replace the contents of buffer in case of error
function! s:FilterBufferOrFail(cmd) abort
  let input = join(getline(0, '$'), "\n")
  let output = system(a:cmd, input)
  if v:shell_error
    call util#error_msg(printf("FilterBufferOrFail: %s\n%s", a:cmd, output))
  else
    call setline(1, split(output, "\n"))
  endif
  return output
endfunction

function! s:ExecPrettier(parser) abort
  let opts = '--write'

  " Try to find .prettierrc.json upwards until the git root.
  let prettierrc_json = findfile('.prettierrc.json', '.;' . util#GetGitRoot())
  if empty(prettierrc_json)
    " Use global prettier config
    " (applicable in sketch buffers or projects that don't have prettier
    " installed)
    let opts .= " --config=" . $DOTFILES_PRIVATE . "/.prettierrc.json"
  endif

  " Check if prettier is installed in the project.
  "
  " 'npx --no -- <pkg>' will fail if <pkg> is not installed,
  " instead of prompting to install <pkg>
  call system('npx --no -- prettier --help')
  if v:shell_error
    " use global prettier
    let prettier_cmd = 'prettier'
  else
    " use local prettier
    let prettier_cmd = 'npx prettier'
  endif

  let path = fnameescape(expand('%:p'))
  if empty(path)
    " No file in disk.
    " Explicitly specifiy parser, since prettier cannot infer from file
    " extension.
    " A parser is not specified in other cases because it could prevent
    " overrides from being applied (e.g., using "go-template" in html files).
    let opts .= ' --parser=' . a:parser
    " Pass buffer content to stdin
    let cmd = printf("%s %s", prettier_cmd, opts)
    execute "%!" . cmd
  endif

  " Pass path to prettier, so it can honor prettierrc overrides related to
  " file extension
  let cmd = printf("%s %s %s", prettier_cmd, opts, path)
  let output = system(cmd)
  if v:shell_error
    call util#error_msg(output)
  endif
  noautocmd silent checktime
endfunction

function! proglang#Prettier(mode) abort
  let prettier_parsers={
  \ 'json': 'json',
  \ 'javascript': 'babel',
  \ 'typescript': 'typescript',
  \ 'typescript.tsx': 'typescript',
  \ 'markdown': 'markdown',
  \ 'html': 'html',
  \ 'xhtml': 'html',
  \ 'css': 'css',
  \ 'yaml': 'yaml'
  \}
  let adhoc_fts = ['c', 'cpp', 'xml', 'go', 'sql']
  let supported_ft = has_key(prettier_parsers, &ft) || index(adhoc_fts, &ft) >= 0

  if !supported_ft
    return util#error_msg('Prettier: Unsupported filetype: ' . &ft)
  endif

  let save_pos = getpos('.')
  silent! update

  if has_key(prettier_parsers, &ft)
    call s:ExecPrettier(prettier_parsers[&ft])
  else
    if &ft == 'c' || &ft == 'cpp'
      let cmd = printf("clang-format --style=Chromium -i '%s'", fnameescape(expand('%:p')))
      let output = system(cmd)
      noautocmd silent checktime
      if v:shell_error
        return util#error_msg('Prettier: Error: clang-format: ' . output)
      endif
      return
    elseif &ft == 'xml'
      call s:FilterBufferOrFail('format-xml')
    elseif &ft == 'go'
      call system('go fmt ' . expand('%:p'))
      noautocmd silent checktime
      return
    elseif &ft == 'sql'
      if a:mode == 'V'
        let range = "'<,'>"
      else
        let range = '%'
      endif
      " https://github.com/zeroturnaround/sql-formatter
      let cmd = 'sql-formatter --lines-between-queries=2'
      if exists('b:sql_language')
        let cmd .= ' --language=' . b:sql_language
      endif
      execute range . '!' . cmd
    else
      return util#error_msg('Unimplemented filetype: ' . &ft)
    endif
  endif

  call setpos('.', save_pos)
  silent! update
endfunction

let s:cmd = ''
function! s:CacheCmd(cmd) abort
  if empty(a:cmd) && empty(s:cmd)
    if &ft == 'go'
      return 'go run %'
    endif
    return ''
  endif
  if !empty(a:cmd)
    let s:cmd = a:cmd
    return s:cmd
  else
    return s:cmd
  endif
endfunction

function! proglang#DispatchAndCapture(cmd) abort
  let cmd = s:CacheCmd(a:cmd)
  if empty(cmd)
    return util#error_msg('DispatchAndCapture: Empty command')
  endif
  update
  silent execute printf("Dispatch! set -o pipefail; %s |& tee /var/tmp/test-results.txt /var/tmp/test-console.txt", cmd)
endfunction

function! proglang#EditSketchBuffer(ft) abort
  let clang_bin = $DOTFILES_PRIVATE . '/sketch/sketch-clang'
  let configs = {
  \  'typescript': {
  \    'path': $DOTFILES_PRIVATE . '/sketch/sketch.ts',
  \    'cmd': 'ts-node --project $DOTFILES_PRIVATE/tsconfig.json %'
  \  },
  \  'javascript': {
  \    'path': $DOTFILES_PRIVATE . '/sketch/sketch.js',
  \    'cmd': 'node %'
  \  },
  \  'go': {
  \    'path': $DOTFILES_PRIVATE . '/sketch/sketch.go',
  \    'cmd': 'go run %'
  \  },
  \  'c': {
  \    'path': $DOTFILES_PRIVATE . '/sketch/sketch.c',
  \    'cmd': printf('gcc -o %s %% && %s', clang_bin, clang_bin)
  \  },
  \  'applescript': {
  \    'path': $DOTFILES_PRIVATE . '/bin/sketch.applescript',
  \    'cmd': '%'
  \  }
  \}
  if !has_key(configs, a:ft)
    return util#error_msg(printf('EditSketchBuffer: unsupported filetype: %s', a:ft))
  endif
  let config = configs[a:ft]
  call window#EditFile(config['path'])
  execute "nnoremap <buffer> <space>t :DispatchAndCapture " . config['cmd'] . "<cr>"
endfunction

function! proglang#ListReferences() abort
  if index(['typescript', 'typescript.tsx'], &ft) != -1
    return proglang#javascript#TsuReferences()
  elseif &ft == 'go'
    GoReferrers
    return
  elseif &ft == 'python'
    YcmCompleter GoToReferences
    return
  else
    return util#error_msg(printf('ListReferences: unsupported filetype: %s', &ft))
  endif
endfunction

function! proglang#ImportSymbol() abort
  if index(['typescript', 'typescript.tsx'], &ft) != -1
    TsuImport
    return
  elseif &ft == 'go'
    GoImports
    return
  else
    return util#error_msg(printf('ImportSymbol: unsupported filetype: %s', &ft))
  endif
endfunction

function! proglang#PrintCurrentFuncName() abort
  if &ft == 'go'
    call proglang#golang#PrintCurrentFuncNameGolang()
  elseif &ft == 'cpp'
    call proglang#cpp#PrintCurrentFuncNameCpp()
  else
    call util#error_msg("PrintCurrentFuncName: unimplemented for filetype: " . &ft)
  endif
endfunction

function! proglang#EditAlternateFile() abort
  if &ft == 'vim'
    return proglang#vimscript#EditAlternateFile()
  endif
  if index(['javascript', 'typescript', 'typescript.tsx', 'go'], &ft) == -1
    return util#error_msg('EditAlternateFile: unsupported file type: ' . &ft)
  endif
  " %     = 'path/to/file.ts'
  " %:r   = 'path/to/file'
  " %:r:r = 'path/to/file'
  " %:e   = 'ts'
  " %:e:e = 'ts'
  "
  " %     = 'path/to/file.test.ts'
  " %:r   = 'path/to/file.test'
  " %:r:r = 'path/to/file'
  " %:e   = 'ts'
  " %:e:e = 'test.ts'
  "
  let root = expand('%:r')
  let ext = expand('%:e')
  if root =~ '[\._]test$'
    let is_test = 1
    if &ft == 'go'
      let candidate_path = substitute(expand('%:r:r'), '_test$', '', 'g') . '.' . ext
    else
      let candidate_path = expand('%:r:r') . '.' . ext
    endif
  else
    let is_test = 0
    if &ft == 'go'
      let test_file_prefix = '_test'
    else
      let test_file_prefix = '.test'
    endif
    let candidate_path = root . test_file_prefix . '.' . ext
  endif
  if !filereadable(candidate_path)
    let candidate_type = is_test ? 'source' : 'test'
    return util#error_msg('EditAlternateFile: ' . candidate_type . ' file not found: ' . candidate_path)
  endif
  let split_type = is_test ? "rightbelow" : "leftabove"
  call util#OpenWindowInTab(candidate_path, split_type . " vsplit")
endfunction

" const s = parse('batata');
" ->
" parse('batata');
function! proglang#ToggleVariable()
  let regex = '\(^\s*\)\([a-zA-Z0-9 \{}]* = \)'
  if getline('.') =~ regex
    call setline('.', substitute(getline('.'), regex, '\1', ''))
  else
    call setline('.', substitute(getline('.'), '\(^\s*\)\(.*\)', '\1a = \2', ''))
    normal! ^
    call feedkeys('cw')
  endif
endfunction

" Helps extract a hard-coded value into a variable.
"
" Given some code like:
" index(['apples', 'bananas'], 'apples')
"
" Change the array with c% and type the name of variable:
" index(fruits, 'apples')
"
" Then call proglang#InsertVariable():
" let fruits = ['apples', 'bananas']
" index(fruits, 'apples')
"
function! proglang#InsertVariable() abort
  if index(['javascript', 'typescript', 'typescript.tsx'], &ft) >= 0
    execute "normal! Oconst\<space>\<c-a>\<space>=\<space>\<c-r>\";"
    normal! =`[
  elseif &ft == 'vim'
    execute "normal! Olet\<space>\<c-a>\<space>=\<space>\<c-r>\""
    normal! =`[
  else
    return util#error_msg('InsertVariable: no support for filetype: ' . &ft)
  endif
endfunction
