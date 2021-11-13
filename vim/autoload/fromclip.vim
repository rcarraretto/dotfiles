function! s:UnpackJsonStr(str) abort
  let str = a:str[1:-2]
  let str = substitute(str, '\\"', '"', 'g')
  let str = substitute(str, '\\n', "\n", 'g')
  return str
endfunction

" Opens a scratch buffer with the contents of the clipboard.
" Formats content if possible.
function! fromclip#BufferFromClipboard(ft, split_count) abort
  call window#SplitFromCount(a:split_count)
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  let str = trim(getreg('*'))
  if a:ft == 'xml' && str[0] == '"' && str[-1:] == '"'
    let str = s:UnpackJsonStr(str)
  endif
  call setline(1, str)
  let &ft = a:ft
  Prettier
endfunction

" Sees prettified version of:
" - stringified json
" - string containing \n
function! s:PreviewJsonFieldValue() abort
  let matches = matchlist(getline('.'), '^\s*"[^"]\+": "\(.*\)"')
  if empty(matches)
    return util#error_msg('PreviewJsonFieldValue: could not extract value')
  endif
  let value = matches[1]
  let split_count = 1
  if value[0] == '{'
    call fromclip#ViewFormattedJson(value, split_count)
    return
  endif
  call window#SplitFromCount(split_count)
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  let b:skip_color_column = 1
  call setline(1, split(value, '\\n'))
endfunction

function! fromclip#ViewFormattedJson(str, split_count) abort
  let str = a:str
  " remove line feed at the end
  if char2nr(str[-1:-1]) == 10
    let str = str[:-2]
  endif
  " replace null character by newline
  let str = substitute(str, '\%x00', '\r', 'g')
  " remove carriage return character (CTRL-V + <cr>)
  let str = substitute(str, '\r', '', 'g')
  " handle stringified json
  if (str[0] == '"' && str[-1:] == '"') || str =~ '^\[\?{\\"'
    if str[0] == '"' && str[-1:] == '"'
      " remove surrounding double quotes
      let str = str[1:-2]
    endif
    " unescape double quotes
    let str = substitute(str, '\\"', '"', 'g')
  endif
  call window#SplitFromCount(a:split_count)
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  let b:skip_color_column = 1
  call setline(1, str)
  set ft=json
  silent %!python -m json.tool
  if v:shell_error
    call setline(1, str)
    return util#error_msg('ViewFormattedJson: invalid json')
  endif
  nnoremap <buffer> K :call <sid>PreviewJsonFieldValue()<cr>
endfunction

function! s:PreviewJsonLine() abort
  call window#CloseUnlistedBuffersInTab()
  call fromclip#ViewFormattedJson(getline('.'), 2)
  noautocmd wincmd p
  noautocmd 50 wincmd |
endfunction

function! fromclip#TogglePreviewJsonLines() abort
  let preview_json_lines = util#ToggleBufVar('preview_json_lines')
  if preview_json_lines == 0
    augroup AutoPreviewJsonLine
      autocmd!
    augroup END
    call window#CloseUnlistedBuffersInTab()
    return
  endif
  augroup AutoPreviewJsonLine
    autocmd!
    let s:save_ut = &updatetime
    autocmd CursorMoved <buffer> set updatetime=100
    autocmd CursorHold <buffer> call s:PreviewJsonLine()
    autocmd BufLeave <buffer> let &updatetime = s:save_ut
  augroup END
  call s:PreviewJsonLine()
endfunction

function! fromclip#JsonSortKeys() abort
  if &ft !=# 'json'
    return util#error_msg('JsonSortKeys: Not a json file')
  endif
  if !executable('jq')
    return util#error_msg("JsonSortKeys: 'jq' tool is not installed")
  endif
  %!jq -S '.'
endfunction
