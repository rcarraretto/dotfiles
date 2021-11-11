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
function! s:GoDocToggle() abort
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

function! proglang#GolangMappings() abort
  nnoremap <buffer> <silent> K :call <sid>GoDocToggle()<cr>
  " vim-go
  " Remove :GoPlay command, as it uploads code to the internet
  " One could accidentally leak sensitive information
  if exists(':GoPlay')
    delcommand GoPlay
  endif
endfunction
