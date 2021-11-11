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
  " Note: This does not properly translate an 'ag' pattern to a vim regex.
  " e.g. \bbatata\b should become \<batata\>
  "
  " Escape forward slash, so @/ can be used later with :substitute
  " (e.g. GetSubstituteTerm())
  let @/ = escape(ag_pattern, '/')
  call feedkeys(":let &hlsearch=1 \| echo\<cr>", "n")
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
    execute printf('Ag -Q -- %s %s', s:AgBuildPattern(a:input), path)
  else
    " Use s:AgVimgrep instead of :Ag to bypass calling s:AgSetHighlight,
    " which is buggy.
    call s:AgVimgrep(printf('%s %s', s:AgSearchFromSearchReg(), path))
  endif
  cfirst
endfunction

" It seems like the search pattern should be surrounded with single quotes
" instead of double quotes.
"
" Else the following search terms wouldn't work: "$#" and "$@".
" I think these would be interpreted by the shell, when in double quotes.
function! s:AgBuildPattern(input) abort
  return printf("'%s'", a:input)
endfunction

function! ag#SearchNotes(input) abort
  execute printf('Ag --hidden -Q -G "\.txt$" -- %s %s', s:AgBuildPattern(a:input), s:GetNoteDirs())
endfunction

function! s:GetNoteDirs() abort
  let dirs = ['~/Dropbox/notes/']
  if isdirectory($HOME . '/Dropbox/notes-home')
    call add(dirs, '~/Dropbox/notes-home')
  endif
  if exists('$NOTES_WORK') && isdirectory($NOTES_WORK)
    call add(dirs, fnameescape($NOTES_WORK))
  endif
  return join(dirs, ' ')
endfunction

function! ag#SearchDotfiles(input) abort
  execute printf("Ag --hidden -Q -- %s %s", s:AgBuildPattern(a:input), util#GetDotfilesDirs())
endfunction

function! ag#SearchInGitRoot(input) abort
  let path = util#GetGitRoot()
  if empty(path)
    let path = util#GetGitRoot({'path': getcwd()})
  endif
  if empty(path)
    return util#error_msg('SearchInGitRoot: Git root not found')
  endif
  execute printf('Ag --hidden -Q -- %s %s', s:AgBuildPattern(a:input), path)
endfunction

function! ag#GrepOperator(type)
  let target = util#YankOperatorTarget(a:type)
  silent execute "Ag -Q --hidden -- " . shellescape(target)
endfunction

function! ag#GrepOperatorInGitRoot(type)
  let target = util#YankOperatorTarget(a:type)
  call ag#SearchInGitRoot(target)
endfunction
