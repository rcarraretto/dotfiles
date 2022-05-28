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
  let adhoc_fts = ['c', 'xml', 'go', 'sql']
  let supported_ft = has_key(prettier_parsers, &ft) || index(adhoc_fts, &ft) >= 0

  if !supported_ft
    return util#error_msg('Prettier: Unsupported filetype: ' . &ft)
  endif

  let save_pos = getpos('.')
  silent! update

  if has_key(prettier_parsers, &ft)
    let parser = prettier_parsers[&ft]
    let opts = '--write --parser=' . parser
    " Try to find .prettierrc.json upwards until the git root.
    " This would be an evidence that the project uses prettier.
    let prettierrc_json = findfile('.prettierrc.json', '.;' . util#GetGitRoot())
    if empty(prettierrc_json)
      " Use global prettier config for example in sketch buffers or
      " projects that don't have prettier installed.
      let opts .= " --config=" . $DOTFILES_PRIVATE . "/.prettierrc"
    endif
    let path = expand('%:p')
    if !empty(path)
      " Pass path to prettier, so it can honor prettierrc overrides related to
      " file extension
      let cmd = printf("npx prettier %s %s", opts, path)
      let output = system(cmd)
      if v:shell_error
        call util#error_msg(output)
      endif
      noautocmd silent checktime
    else
      " No file in disk. Pass buffer content to stdin.
      let cmd = printf("npx prettier %s", opts)
      execute "%!" . cmd
    endif
  else
    if &ft == 'c'
      let cmd = printf("clang-format --style=Chromium -i '%s'", fnameescape(expand('%:p')))
      let output = system(cmd)
      noautocmd silent checktime
      if v:shell_error
        return util#error_msg('Prettier: Error: clang-format: ' . output)
      endif
      return
    elseif &ft == 'xml'
      " https://stackoverflow.com/a/16090892
      let cmd = "python -c 'import sys;import xml.dom.minidom;s=sys.stdin.read();print(xml.dom.minidom.parseString(s).toprettyxml())'"
      call s:FilterBufferOrFail(cmd)
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

function! s:DispatchAndLogOutput(cmd) abort
  silent execute printf("Dispatch! %s |& tee /var/tmp/test-results.txt /var/tmp/test-console.txt", a:cmd)
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
  execute "nnoremap <buffer> <space>t :update <bar> call <sid>DispatchAndLogOutput('" . config['cmd'] . "')<cr>"
endfunction

" Wrap :TsuReferences (from tsuquyomi)
" Use quickfix list instead of location list
function! s:TsuReferences() abort
  TsuReferences
  lclose
  let items = getloclist(winnr())
  for item in items
    " Fix references to files outside of cwd().
    "
    " For some reason, when references are outside of cwd(), the
    " quickfix/location list does not jump properly.
    "
    " When this happens, the listed file paths contain ~ instead of a full
    " reference to $HOME. Maybe this could be the reason.
    "
    " To work around this problem, unset 'bufnr' and use the 'filename' feature
    " instead.
    "
    " :h setqflist
    "
    let item['filename'] = fnamemodify(bufname(item['bufnr']), ':p')
    unlet item['bufnr']
  endfor
  call setqflist(items, 'r')
  copen
  wincmd J
  wincmd p
endfunction

function! proglang#ListReferences() abort
  if index(['typescript', 'typescript.tsx'], &ft) != -1
    return s:TsuReferences()
  elseif &ft == 'go'
    GoReferrers
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

function! proglang#TypescriptReload()
  " TsReloadProject
  call tsuquyomi#reloadProject()
  " TsReload
  call tsuquyomi#reload()
endfunction

function! proglang#JavascriptConfig()
  command! -buffer JsMethodToFunc call proglang#JavascriptMethodToFunc()
  command! -buffer ShowTsError echo getloclist(0)[0]['text']
endfunction

" Adapted version of :GoDoc from vim-go:
" - When the popup is already open, close it
" - Set the popup to close with any cursor move
function! proglang#GoDocToggle() abort
  if empty(popup_list())
    GoDoc
    let popup_ids = popup_list()
    if empty(popup_ids)
      return
    endif
    call popup_setoptions(popup_ids[0], {'moved': 'any'})
  else
    call popup_clear()
  endif
endfunction

function! proglang#GolangConfig() abort
  " vim-go
  " Remove :GoPlay command, as it uploads code to the internet
  " One could accidentally leak sensitive information
  if exists(':GoPlay')
    delcommand GoPlay
  endif
endfunction

function! s:PrintCurrentFuncNameGolang() abort
  let winview = winsaveview()
  " go to top of function (vim-go)
  noautocmd normal [[
  let line = getline('.')
  noautocmd execute "normal \<c-o>"
  " fix scroll position that was changed by <c-o>
  call winrestview(winview)
  " Delay the echo.
  " Else calling this function right after switching lines has the side effect
  " of the echo being erased by some other code.
  " Maybe this is related to some plugin using a Cursor autocmd.
  call util#delayed_echo(line)
endfunction

function! s:PrintCurrentFuncNameCpp() abort
  let winview = winsaveview()
  " go to top of method. cursor will be on {
  noautocmd normal [m
  if match(getline('.'), '^\s*{') >= 0
    " {'s are on a dedicated line
    normal! k
  endif
  if stridx(getline('.'), '(') == -1
    " method definition too long
    if stridx(getline('.'), ')') >= 0
      normal! f)
      normal! %
    endif
  endif
  let line = getline('.')
  noautocmd execute "normal \<c-o>"
  " fix scroll position that was changed by <c-o>
  call winrestview(winview)
  " Extract method name only (no return value or args)
  let method_name = matchstr(trim(line), '.* \zs[^(]\+\ze(')
  if len(method_name)
    echo method_name
    return
  endif
  " Couldn't find it via [m, so maybe it is inside a function.
  "
  " The [{ motion will only work if the current line is an expression
  " directly inside the function (not nested in an if, switch, etc).
  " Therefore, better to jump to a candidate location, then to print
  " inaccurate info.
  call util#error_msg("Method not found. Jumping to block...")
  normal! [{
  normal! zz
endfunction

function! proglang#PrintCurrentFuncName() abort
  if &ft == 'go'
    call s:PrintCurrentFuncNameGolang()
  elseif &ft == 'cpp'
    call s:PrintCurrentFuncNameCpp()
  else
    call util#error_msg("PrintCurrentFuncName: unimplemented for filetype: " . &ft)
  endif
endfunction

function! proglang#EditTestFile() abort
  if index(['javascript', 'typescript', 'typescript.tsx', 'go'], &ft) == -1
    return util#error_msg('EditTestFile: unsupported file type: ' . &ft)
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
    return util#error_msg('EditTestFile: ' . candidate_type . ' file not found: ' . candidate_path)
  endif
  let split_type = is_test ? "rightbelow" : "leftabove"
  call util#OpenWindowInTab(candidate_path, split_type . " vsplit")
endfunction

" Logs the last variable that was declared or assigned
function! proglang#JavascriptLogVariable(snippet)
  let save_pos = getpos('.')
  normal ^
  " e.g.
  " x.y = new Date();
  " const x = a[a.length - 1];
  " const x: Module.Struct = {
  " let response = await admin.api.post(`/api/entities/${id}`);
  let pattern = '^\s*\(const \|let \|\)\([[:alnum:]\.]\+\)\(: [[:alnum:]\.]\+\)\? ='
  call search(pattern, 'b')
  let matches = matchlist(getline('.'), pattern)
  if len(matches)
    let @" = matches[2]
  endif
  call setpos('.', save_pos)
  if len(matches)
    silent execute "normal o" . a:snippet . "\<tab>\<c-r>\"\<esc>"
    " Transform change into a single undo item
    silent execute "normal! yyu"
    silent execute "normal! up"
  endif
endfunction

function! proglang#JavascriptMethodToFunc() abort
  " Case 1 (no args)
  " public async someMethod(): Promise<Response> {
  " const someMethod = async (): Promise<Response> => {
  "
  " Case 2 (with args)
  " public async someMethod(request: object): Promise<object> {
  " const someMethod = async (request: object): Promise<object> {
  "
  let matches = matchlist(getline('.'), '^\(\s*\)\(public\|private\)\s\?\(async\)\?\s\?\([^(]*\)(\([^)]*\)): \(.*\) {')
  if empty(matches)
    return util#error_msg('JsMethodToFunc: line does not match')
  endif
  let indent = matches[1]
  let asyncToken = matches[3]
  if !empty(asyncToken)
    let asyncToken .= ' '
  endif
  let methodName = matches[4]
  let args = matches[5]
  let returnType = matches[6]
  let line = printf("%sconst %s = %s(%s): %s => {", indent, methodName, asyncToken, args, returnType)
  call setline('.', line)
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

function! proglang#SearchTerraformResource() abort
  let matches = matchlist(getline('.'), '\(resource\|data\) "\([^"]\+\)" "\([^"]\+\)"')
  if len(matches) == 0
    return util#error_msg('SearchTerraformResource: cursor not on resource|data')
  endif
  let resource_type = matches[2]
  let local_name = matches[3]
  let @/ = resource_type . '.' . local_name
  try
    normal! n
    normal! zz
  catch /E486/
    return util#echo_exception()
  endtry
  " needs to be last, else exception message is overwritten
  call search#Highlight()
endfunction
