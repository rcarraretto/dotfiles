function! proglang#javascript#Config()
  command! -buffer JsMethodToFunc call proglang#javascript#JavascriptMethodToFunc()
  command! -buffer ShowTsError echo getloclist(0)[0]['text']
endfunction

function! proglang#javascript#JavascriptMethodToFunc() abort
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

function! proglang#javascript#TypescriptReload()
  " TsReloadProject
  call tsuquyomi#reloadProject()
  " TsReload
  call tsuquyomi#reload()
endfunction

" Wrap :TsuReferences (from tsuquyomi)
" Use quickfix list instead of location list
function! proglang#javascript#TsuReferences() abort
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
  call setqflist(items)
  botright copen
  wincmd p
endfunction

" Logs the last variable that was declared or assigned
function! proglang#javascript#JavascriptLogVariable(snippet)
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
