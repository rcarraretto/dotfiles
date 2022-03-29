" Replacement for netrw 'gx',
" but just for urls
function! url#OpenUrl() abort
  let url = expand('<cWORD>')
  if url !~ 'http\(s\)\?:\/\/'
    return util#error_msg('OpenUrl: not a url: ' . url)
  endif
  call system("open " . shellescape(url))
  redraw!
endfunction

function! url#ParseUrlQs() abort
  let url = expand('<cWORD>')
  if url !~ 'http\(s\)\?:\/\/'
    return util#error_msg('ParseUrlQs: not a url: ' . url)
  endif
  let did_split = window#SplitFromCount(v:count)
  if !did_split
    new
  endif
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile wrap
  set ft=json
  execute "%!parse-qs " . shellescape(fnameescape(url))
endfunction
