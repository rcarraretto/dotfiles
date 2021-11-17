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
  \ 'css': 'css',
  \ 'yaml': 'yaml'
  \}
  let adhoc_fts = ['xml', 'go', 'sql']
  let supported_ft = has_key(prettier_parsers, &ft) || index(adhoc_fts, &ft) >= 0

  if !supported_ft
    return util#error_msg('Prettier: Unsupported filetype: ' . &ft)
  endif

  let save_pos = getpos('.')
  silent! update

  if has_key(prettier_parsers, &ft)
    let parser = prettier_parsers[&ft]
    let opts = ''
    " Try to find .prettierrc.json upwards until the git root.
    " This would be an evidence that the project uses prettier.
    let prettierrc_json = findfile('.prettierrc.json', '.;' . util#GetGitRoot())
    if empty(prettierrc_json)
      " Use global prettier config for example in sketch buffers or
      " projects that don't have prettier installed.
      let opts = "--config=" . $DOTFILES_PRIVATE . "/.prettierrc "
    endif
    execute "%!npx prettier " . opts . "--parser=" . parser
  else
    if &ft == 'xml'
      " https://stackoverflow.com/a/16090892
      let cmd = "python -c 'import sys;import xml.dom.minidom;s=sys.stdin.read();print(xml.dom.minidom.parseString(s).toprettyxml())'"
      call s:FilterBufferOrFail(cmd)
    elseif &ft == 'go'
      call system('go fmt ' . expand('%:p'))
      silent checktime
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
  let configs = {
  \  'typescript': {
  \    'path': $DOTFILES_PRIVATE . '/src/sketch.ts',
  \    'cmd': 'ts-node --project $DOTFILES_PRIVATE/tsconfig.json %'
  \  },
  \  'javascript': {
  \    'path': $DOTFILES_PRIVATE . '/src/sketch.js',
  \    'cmd': 'node %'
  \  },
  \  'go': {
  \    'path': $DOTFILES_PRIVATE . '/src/sketch.go',
  \    'cmd': 'go run %'
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

function! s:ImportSymbol() abort
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
