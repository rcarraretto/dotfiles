function! editing#TrimWhitespace()
  if &modifiable == 0
    return
  endif
  if get(b:, 'skip_trim_whitespace')
    return
  endif
  let save_cursor = getpos('.')
  if &ft == 'markdown'
    " Keep 2 trailing whitespaces.
    "
    " https://daringfireball.net/projects/markdown/syntax#p
    "
    " "When you do want to insert a <br /> break tag using Markdown, you end a line
    " with two or more spaces, then type return."
    "
    %s/\(^\s\+$\|\S\zs\s$\|\S\zs\s\{3,\}$\)//e
  else
    %s/\s\+$//e
  endif
  call setpos('.', save_cursor)
endfunction

function! editing#FormatParagraph() abort
  if getline('.')[0] == '|'
    " table (using easy-align)
    let save_pos = getpos('.')
    normal gaip*|
    call setpos('.', save_pos)
  else
    " paragraph
    normal! gqip
  endif
endfunction

function! editing#ChangeQuotes()
  let line = getline('.')
  let sline = line
  if match(sline, "`") >= 0
    let sline = substitute(sline, "`", "'", 'g')
  elseif match(sline, "'") != -1
    let sline = substitute(sline, "'", '"', 'g')
  elseif match(sline, '"') != -1
    let sline = substitute(sline, '"', "'", 'g')
  endif
  let sline = substitute(sline, "[“”„‘’]", '"', 'g')
  if line == sline
    echom "no changes"
    return
  endif
  call setline('.', sline)
endfunction
