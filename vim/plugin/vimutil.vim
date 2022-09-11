command! CaptureRuntime call vimutil#CaptureRuntime()
command! ListCtrlMappings call vimutil#ListCtrlMappings()
command! -nargs=1 GoToDefinition call vimutil#GoToDefinition(<q-args>)
command! -nargs=1 -complete=command GoToCommandDefinition call vimutil#GoToCommandDefinition(<q-args>)

" :Log {expr}
"
" Based on :PPmsg from scriptease
" ~/.vim/bundle/vim-scriptease/plugin/scriptease.vim:41:11
"
" Pretty print the value of {expr} using :echomsg
" Extended to also:
" - log to a special file
" - yank {expr} and result
"
" Example:
" :Log
" :Log 2 + 2
" :Log range(1, 5)
" :Log b:
"
" It has to be implemented inline in order for eval(<q-args>) and expand('<sfile>')
" to work properly.
"
" Variables inside the expression below are prefixed with underscore
" to avoid polluting the other function's scope.
" e.g. if the other function has a variable named 'lines', this could be a problem:
" Log lines
" == (expression is expanded) ==>
" let lines = []
" eval('lines')
"
command! -complete=expression -nargs=? Log
      \ let _lines = [] |
      \ let _is_error = 0 |
      \ try |
      \   if !empty(<q-args>) |
      \     let _lines = <sid>LogExprResult(eval(<q-args>)) |
      \   elseif !empty(expand('<sfile>')) |
      \     let _lines = [expand('<sfile>') . ', line ' . expand('<slnum>')] |
      \   endif |
      \ catch |
      \   let _lines = [matchstr(v:exception, 'Vim.*:\zsE\d\+: .*')] |
      \   let _is_error = 1 |
      \ endtry |
      \ call s:LogLines(_lines, {'qargs': <q-args>, 'sfile': expand('<sfile>'), 'is_error': _is_error})

function! s:LogExprResult(result) abort
  return split(scriptease#dump(a:result, {'width': &columns - 1}), "\n")
endfunction

function! s:LogLines(lines, opts) abort
  if empty(a:lines)
    " :Log on cmd-line without args
    return
  endif
  let qargs = get(a:opts, 'qargs', 0)
  let sfile = get(a:opts, 'sfile', 0)
  let is_error = get(a:opts, 'is_error', 0)
  for line in a:lines
    if is_error
      echohl ErrorMsg
      echomsg line
      echohl NONE
    else
      echomsg line
    endif
  endfor
  if empty(sfile)
    " Copy to clipboard, but only if :Log was called from cmd-line
    " (and not within a script).
    let @* = qargs . "\n> " . join(a:lines, "\n")
  endif
  let a:lines[0] = printf('[%s] %s', strftime('%H:%M:%S'), a:lines[0])
  call writefile(a:lines, "/var/tmp/vim-messages.txt", "a")
  call fs#RefreshBuffer("/var/tmp/vim-messages.txt")
endfunction

augroup AuxiliaryBuffersConfig
  autocmd!
  autocmd VimEnter * call writefile([], "/var/tmp/vim-messages.txt")
  autocmd BufRead /var/tmp/vim-messages.txt,/private/var/tmp/vim-messages.txt,
        \/var/tmp/debug.log,/private/var/tmp/debug.log
        \ set ft=vim_log
        \| let b:skip_color_column=1
        \| let b:skip_cursor_line=1
        \| let b:parenmatch=0
        \| setlocal nonumber norelativenumber
  autocmd BufRead /var/tmp/test-results.txt let b:skip_trim_whitespace = 1
augroup END
