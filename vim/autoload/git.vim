" Open repo in SourceTree
function! git#OpenInSourceTree()
  let output = util#GetGitRoot()
  if empty(output)
    echohl ErrorMsg
    echom "OpenInSourceTree: couldn't find git root"
    echohl NONE
    return
  endif
  call system('open -a SourceTree ' . fnameescape(output))
endfunction

" Show git history for file.
" If dirvish buffer, show git history for folder.
function! git#GlogFileHistory() abort
  " uses fugitive :Git
  Git log --pretty=format:"%h | %<(20,trunc)%an | %s" %
endfunction
