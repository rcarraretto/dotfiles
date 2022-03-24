function! s:StatelessGrep(prg, format, args) abort
  let prg_back = &l:grepprg
  let format_back = &grepformat
  try
    let &l:grepprg = a:prg
    let &grepformat = a:format
    " Escape special chars because of vim cmdline, to avoid e.g.:
    " E499: Empty file name for '%' or '#', only works with ":p:h"
    let args = escape(a:args, '|#%')
    silent execute 'grep!' args
  finally
    let &l:grepprg = prg_back
    let &grepformat = format_back
  endtry
  " fix screen going blank after :grep
  redraw!
  botright copen
endfunction

function! s:AgVimgrep(args) abort
  call s:StatelessGrep('ag --vimgrep', '%f:%l:%c:%m,%f:%l:%m', a:args)
endfunction

function! s:AgSetHighlight(ag_args) abort
  " Get the last segment that is surrounded by quotes.
  " (does not work if the pattern is not surrounded by quotes)
  let ag_pattern = matchstr(a:ag_args, '\v^.*[''"]\zs.{-}\ze[''"]')
  if empty(ag_pattern)
    echom "WARN: AgSetHighlight: could not find search pattern: " . a:ag_args
    return
  endif
  " Note: This does not properly translate an 'ag' pattern to a vim regex.
  " e.g. \bbatata\b should become \<batata\>
  "
  " Escape forward slash, so @/ can be used later with :substitute
  " (e.g. GetSubstituteTerm())
  let @/ = escape(ag_pattern, '/')
  call search#Highlight()
endfunction

function! s:AgSearchFromSearchReg() abort
  let search = getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search, '\(\\<\|\\>\)', '\\b', 'g')
  return '"' . search . '"'
endfunction

" :Ag command.
" Based on ack.vim (ack#Ack)
function! ag#Ag(args) abort
  if empty(a:args)
    return s:AgVimgrep(s:AgSearchFromSearchReg())
  endif
  call s:AgVimgrep(a:args)
  call s:AgSetHighlight(a:args)
endfunction

function! ag#SearchInFile(input) abort
  let path = expand('%:p')
  if empty(path)
    echohl ErrorMsg
    echom 'SearchInFile: current buffer has invalid path'
    echohl NONE
    return
  endif
  if isdirectory(path)
    echohl ErrorMsg
    echom 'SearchInFile: current buffer is a directory'
    echohl NONE
    return
  endif
  if !empty(a:input)
    execute printf('Ag -Q -- %s %s', shellescape(a:input), path)
  else
    " Use s:AgVimgrep instead of :Ag to bypass calling s:AgSetHighlight,
    " which is buggy.
    call s:AgVimgrep(printf('%s %s', s:AgSearchFromSearchReg(), path))
  endif
  cfirst
endfunction

function! ag#SearchNotes(input) abort
  execute printf('Ag --hidden -Q -G "\.txt$" -- %s %s', shellescape(a:input), s:GetNoteDirs())
endfunction

function! s:GetNoteDirs() abort
  let dirs = []
  if exists('$NOTES_SHARED') && isdirectory($NOTES_SHARED)
    call add(dirs, fnameescape($NOTES_SHARED))
  endif
  if exists('$NOTES_HOME') && isdirectory($NOTES_HOME)
    call add(dirs, fnameescape($NOTES_HOME))
  endif
  if exists('$NOTES_WORK') && isdirectory($NOTES_WORK)
    call add(dirs, fnameescape($NOTES_WORK))
  endif
  return join(dirs, ' ')
endfunction

function! ag#SearchDotfiles(input) abort
  execute printf("Ag --hidden -Q -- %s %s", shellescape(a:input), util#GetDotfilesDirs())
endfunction

function! ag#SearchInGitRoot(input) abort
  let path = util#GetGitRoot()
  if empty(path)
    let path = util#GetGitRoot({'path': getcwd()})
  endif
  if empty(path)
    return util#error_msg('SearchInGitRoot: Git root not found')
  endif
  execute printf('Ag --hidden -Q -- %s %s', shellescape(a:input), fnameescape(path))
endfunction

function! ag#SearchArglist(input) abort
  if argc() == 0
    return util#error_msg('SearchArglist: Empty arglist')
  endif
  execute printf("Ag --hidden -Q -- %s %s", shellescape(a:input), expand('##'))
endfunction

function! ag#GrepOperator(type) abort
  let [target, error] = util#YankOperatorTarget(a:type)
  if !empty(error)
    return util#error_msg('GrepOperator: ' . error)
  endif
  let ctx = get(g:, 'grep_operator_ctx', 'cwd')
  if ctx != 'cwd'
    " echo needs to be delayed because of 'redraw' in StatelessGrep
    call util#delayed_echo(printf("grep_operator_ctx='%s'", ctx))
  endif
  if ctx == 'arglist'
    call ag#SearchArglist(target)
  elseif ctx == 'dotfiles'
    call ag#SearchDotfiles(target)
  else
    silent execute printf("Ag -Q --hidden -- %s", shellescape(target))
  endif
endfunction

function! ag#SelectGrepOperatorCtx() abort
  let opts = ['cwd', 'arglist', 'dotfiles']
  let ctx = util#inputlist(opts, {'intro': 'Select g:grep_operator_ctx:'})
  if empty(ctx)
    return
  endif
  let g:grep_operator_ctx = ctx
  echom printf("let g:grep_operator_ctx='%s'", ctx)
endfunction

function! ag#GrepOperatorInGitRoot(type)
  let [target, error] = util#YankOperatorTarget(a:type)
  if !empty(error)
    return util#error_msg('GrepOperatorInGitRoot: ' . error)
  endif
  call ag#SearchInGitRoot(target)
endfunction

" Adapted from Cfind from enuch.vim
" ~/.vim/bundle/vim-eunuch/plugin/eunuch.vim
"
" Cfind! . -type f -name '*.spec.ts'
" =>
" SearchExtension .spec.ts
"
" Adapted to:
" - use 'ag' (grepprg) instead of 'find'
" - open quickfix but not focus on it
"
function! ag#SearchExtension(ext)
  try
    let grepformat = &l:grepformat
    setlocal grepformat=%f
    silent execute 'grep! -g "\.' . a:ext . '"'
    redraw!
    botright copen
    wincmd p
  finally
    let &l:grepformat = grepformat
  endtry
endfunction
