function! search#Highlight() abort
  call feedkeys(":let &hlsearch=1 \| echo\<cr>", "n")
endfunction

" Make * and # work on visual mode.
" From https://github.com/nelstrom/vim-visual-star-search
function! search#VisualStar(cmdtype)
  let temp = @s
  normal! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" Similar to star (*) but for arbitrary motions,
" instead of just the word under cursor.
function! search#SearchOperator(type)
  let [target, error] = util#YankOperatorTarget(a:type)
  if !empty(error)
    return util#error_msg('SearchOperator: ' . error)
  endif
  let @/ = escape(target, '\')
  call search#Highlight()
endfunction

function! search#SearchLine() abort
  let @/ = escape(getline('.'), '\')
  call search#Highlight()
endfunction

" :SW command.
" (Wrapper for :Subvert from abolish.vim)
" :Subvert changes the search register when called directly.
" By using this wrap, this can be avoided.
function! search#SubvertWrap(line1, line2, count, args)
  let save_cursor = getpos('.')
  try
    if a:count == 0
      execute "Subvert" . a:args
    else
      execute a:line1 . "," . a:line2 . "Subvert" . a:args
    endif
  catch
    echohl ErrorMsg
    echo v:errmsg
    echohl NONE
  endtry
  call setpos('.', save_cursor)
  return ""
endfunction

function! search#SubvertTerm()
  let str = search#Term()
  " Make first char lower case,
  " so that the :Subvert replace is always case-aware.
  return tolower(str[0]) . str[1:]
endfunction

function! search#Term()
  " Handle search#VisualStar.
  "
  " "\Vbatata" => "batata"
  "
  " Note: \V has a special meaning in vim regex,
  " therefore we need to write \\V to match "\V".
  if match(@/, '^\\V\(.*\)') != -1
    return matchlist(@/, '^\\V\(.*\)')[1]
  endif

  " Remove the word boundary atoms
  " that will be present when searching with * and #.
  "
  " "\<batata\>" => "batata"
  "
  " Note: \< and \> have a special meaning in vim regex (word boundary),
  " therefore we need to write \\< and \\> to match "\<" and "\>".
  if match(@/, '^\\<\(.*\)\\>$') != -1
    return matchlist(@/, '^\\<\(.*\)\\>$')[1]
  endif

  return @/
endfunction

" Given the current search term, show the uniques matches.
" (The current search term should have a pattern)
" Based on https://vi.stackexchange.com/a/8914
function! search#ShowUniqueSearchMatches() abort
  let matches = []
  silent execute '%s//\=add(matches, submatch(0))/nge'
  if empty(matches)
    return util#error_msg('ShowUniqueSearchMatches: no matches: ' . @/)
  endif
  call uniq(sort(matches))
  let str = join(matches, "\n")
  " Open buffer with results
  new
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  noautocmd silent! 1put= str
  noautocmd silent! 1delete _
  call feedkeys(":nohlsearch\<cr>")
endfunction
