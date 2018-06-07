" unimpaired.vim - Pairs of handy bracket mappings
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.2
" GetLatestVimScripts: 1590 1 :AutoInstall: unimpaired.vim

if exists("g:loaded_unimpaired") || &cp || v:version < 700
  finish
endif
let g:loaded_unimpaired = 1

function! s:map(mode, lhs, rhs, ...) abort
  let flags = (a:0 ? a:1 : '') . (a:rhs =~# '^<Plug>' ? '' : '<script>')
  exe a:mode . 'map' flags a:lhs a:rhs
endfunction

" Next and previous {{{1

function! s:MapNextFamily(map,cmd) abort
  let map = '<Plug>unimpaired'.toupper(a:map)
  let cmd = '".(v:count ? v:count : "")."'.a:cmd
  let end = '"<CR>'.(a:cmd == 'l' || a:cmd == 'c' ? 'zv' : '')
  execute 'nnoremap <silent> '.map.'Previous :<C-U>exe "'.cmd.'previous'.end
  execute 'nnoremap <silent> '.map.'Next     :<C-U>exe "'.cmd.'next'.end
  execute 'nnoremap <silent> '.map.'First    :<C-U>exe "'.cmd.'first'.end
  execute 'nnoremap <silent> '.map.'Last     :<C-U>exe "'.cmd.'last'.end
  call s:map('n', '['.        a:map , map.'Previous')
  call s:map('n', ']'.        a:map , map.'Next')
  call s:map('n', '['.toupper(a:map), map.'First')
  call s:map('n', ']'.toupper(a:map), map.'Last')
  if exists(':'.a:cmd.'nfile')
    execute 'nnoremap <silent> '.map.'PFile :<C-U>exe "'.cmd.'pfile'.end
    execute 'nnoremap <silent> '.map.'NFile :<C-U>exe "'.cmd.'nfile'.end
    call s:map('n', '[<C-'.toupper(a:map).'>', map.'PFile')
    call s:map('n', ']<C-'.toupper(a:map).'>', map.'NFile')
  endif
endfunction

call s:MapNextFamily('a','')
call s:MapNextFamily('b','b')
call s:MapNextFamily('l','l')
call s:MapNextFamily('q','c')
call s:MapNextFamily('t','t')

function! s:entries(path)
  let path = substitute(a:path,'[\\/]$','','')
  let files = split(glob(path."/.*"),"\n")
  let files += split(glob(path."/*"),"\n")
  call map(files,'substitute(v:val,"[\\/]$","","")')
  call filter(files,'v:val !~# "[\\\\/]\\.\\.\\=$"')

  let filter_suffixes = substitute(escape(&suffixes, '~.*$^'), ',', '$\\|', 'g') .'$'
  call filter(files, 'v:val !~# filter_suffixes')

  return files
endfunction

function! s:FileByOffset(num)
  let file = expand('%:p')
  if file == ''
    let file = getcwd() . '/'
  endif
  let num = a:num
  while num
    let files = s:entries(fnamemodify(file,':h'))
    if a:num < 0
      call reverse(sort(filter(files,'v:val <# file')))
    else
      call sort(filter(files,'v:val ># file'))
    endif
    let temp = get(files,0,'')
    if temp == ''
      let file = fnamemodify(file,':h')
    else
      let file = temp
      let found = 1
      while isdirectory(file)
        let files = s:entries(file)
        if empty(files)
          let found = 0
          break
        endif
        let file = files[num > 0 ? 0 : -1]
      endwhile
      let num += (num > 0 ? -1 : 1) * found
    endif
  endwhile
  return file
endfunction

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

nnoremap <silent> <Plug>unimpairedDirectoryNext     :<C-U>edit <C-R>=<SID>fnameescape(fnamemodify(<SID>FileByOffset(v:count1), ':.'))<CR><CR>
nnoremap <silent> <Plug>unimpairedDirectoryPrevious :<C-U>edit <C-R>=<SID>fnameescape(fnamemodify(<SID>FileByOffset(-v:count1), ':.'))<CR><CR>
call s:map('n', ']f', '<Plug>unimpairedDirectoryNext')
call s:map('n', '[f', '<Plug>unimpairedDirectoryPrevious')

nmap <silent> <Plug>unimpairedONext     <Plug>unimpairedDirectoryNext:echohl WarningMSG<Bar>echo "]o is deprecated. Use ]f"<Bar>echohl NONE<CR>
nmap <silent> <Plug>unimpairedOPrevious <Plug>unimpairedDirectoryPrevious:echohl WarningMSG<Bar>echo "[o is deprecated. Use [f"<Bar>echohl NONE<CR>
call s:map('n', ']o', '<Plug>unimpairedONext')
call s:map('n', '[o', '<Plug>unimpairedOPrevious')

" }}}1
" Line operations {{{1

function! s:BlankUp(count) abort
  put!=repeat(nr2char(10), a:count)
  ']+1
  silent! call repeat#set("\<Plug>unimpairedBlankUp", a:count)
endfunction

function! s:BlankDown(count) abort
  put =repeat(nr2char(10), a:count)
  '[-1
  silent! call repeat#set("\<Plug>unimpairedBlankDown", a:count)
endfunction

nnoremap <silent> <Plug>unimpairedBlankUp   :<C-U>call <SID>BlankUp(v:count1)<CR>
nnoremap <silent> <Plug>unimpairedBlankDown :<C-U>call <SID>BlankDown(v:count1)<CR>

call s:map('n', '[<Space>', '<Plug>unimpairedBlankUp')
call s:map('n', ']<Space>', '<Plug>unimpairedBlankDown')

function! s:ExecMove(cmd) abort
  let old_fdm = &foldmethod
  if old_fdm != 'manual'
    let &foldmethod = 'manual'
  endif
  normal! m`
  silent! exe a:cmd
  norm! ``
  if old_fdm != 'manual'
    let &foldmethod = old_fdm
  endif
endfunction

function! s:Move(cmd, count, map) abort
  call s:ExecMove('move'.a:cmd.a:count)
  silent! call repeat#set("\<Plug>unimpairedMove".a:map, a:count)
endfunction

function! s:MoveSelectionUp(count) abort
  call s:ExecMove("'<,'>move'<--".a:count)
  silent! call repeat#set("\<Plug>unimpairedMoveSelectionUp", a:count)
endfunction

function! s:MoveSelectionDown(count) abort
  call s:ExecMove("'<,'>move'>+".a:count)
  silent! call repeat#set("\<Plug>unimpairedMoveSelectionDown", a:count)
endfunction

nnoremap <silent> <Plug>unimpairedMoveUp            :<C-U>call <SID>Move('--',v:count1,'Up')<CR>
nnoremap <silent> <Plug>unimpairedMoveDown          :<C-U>call <SID>Move('+',v:count1,'Down')<CR>
noremap  <silent> <Plug>unimpairedMoveSelectionUp   :<C-U>call <SID>MoveSelectionUp(v:count1)<CR>
noremap  <silent> <Plug>unimpairedMoveSelectionDown :<C-U>call <SID>MoveSelectionDown(v:count1)<CR>

call s:map('n', '[e', '<Plug>unimpairedMoveUp')
call s:map('n', ']e', '<Plug>unimpairedMoveDown')
call s:map('x', '[e', '<Plug>unimpairedMoveSelectionUp')
call s:map('x', ']e', '<Plug>unimpairedMoveSelectionDown')

" }}}1
" Option toggling {{{1

function! s:statusbump() abort
  let &l:readonly = &l:readonly
  return ''
endfunction

function! s:toggle(op) abort
  call s:statusbump()
  return eval('&'.a:op) ? 'no'.a:op : a:op
endfunction

function! s:cursor_options() abort
  return &cursorline && &cursorcolumn ? 'nocursorline nocursorcolumn' : 'cursorline cursorcolumn'
endfunction

function! s:option_map(letter, option, mode) abort
  call s:map('n', '[o'.a:letter, ':'.a:mode.' '.a:option.'<C-R>=<SID>statusbump()<CR><CR>')
  call s:map('n', ']o'.a:letter, ':'.a:mode.' no'.a:option.'<C-R>=<SID>statusbump()<CR><CR>')
  call s:map('n', '=o'.a:letter, ':'.a:mode.' <C-R>=<SID>toggle("'.a:option.'")<CR><CR>')
endfunction

call s:map('n', '[ob', ':set background=light<CR>')
call s:map('n', ']ob', ':set background=dark<CR>')
call s:map('n', '=ob', ':set background=<C-R>=&background == "dark" ? "light" : "dark"<CR><CR>')
call s:option_map('c', 'cursorline', 'setlocal')
call s:option_map('u', 'cursorcolumn', 'setlocal')
call s:map('n', '[od', ':diffthis<CR>')
call s:map('n', ']od', ':diffoff<CR>')
call s:map('n', '=od', ':<C-R>=&diff ? "diffoff" : "diffthis"<CR><CR>')
call s:option_map('h', 'hlsearch', 'set')
call s:option_map('i', 'ignorecase', 'set')
call s:option_map('l', 'list', 'setlocal')
call s:option_map('n', 'number', 'setlocal')
call s:option_map('r', 'relativenumber', 'setlocal')
call s:option_map('s', 'spell', 'setlocal')
call s:option_map('w', 'wrap', 'setlocal')
call s:map('n', '[ov', ':set virtualedit+=all<CR>')
call s:map('n', ']ov', ':set virtualedit-=all<CR>')
call s:map('n', '=ov', ':set <C-R>=(&virtualedit =~# "all") ? "virtualedit-=all" : "virtualedit+=all"<CR><CR>')
call s:map('n', '[ox', ':set cursorline cursorcolumn<CR>')
call s:map('n', ']ox', ':set nocursorline nocursorcolumn<CR>')
call s:map('n', '=ox', ':set <C-R>=<SID>cursor_options()<CR><CR>')
if empty(maparg('co', 'n'))
  nmap co =o
endif

function! s:setup_paste() abort
  let s:paste = &paste
  let s:mouse = &mouse
  set paste
  set mouse=
  augroup unimpaired_paste
    autocmd!
    autocmd InsertLeave *
          \ if exists('s:paste') |
          \   let &paste = s:paste |
          \   let &mouse = s:mouse |
          \   unlet s:paste |
          \   unlet s:mouse |
          \ endif |
          \ autocmd! unimpaired_paste
  augroup END
endfunction

nnoremap <silent> <Plug>unimpairedPaste :call <SID>setup_paste()<CR>

call s:map('n', 'yo', ':call <SID>setup_paste()<CR>o', '<silent>')
call s:map('n', 'yO', ':call <SID>setup_paste()<CR>O', '<silent>')

" }}}1
" Put {{{1

function! s:putline(how, map) abort
  let [body, type] = [getreg(v:register), getregtype(v:register)]
  call setreg(v:register, body, 'l')
  exe 'normal! "'.v:register.a:how
  call setreg(v:register, body, type)
  if type !=# 'V'
    silent! call repeat#set("\<Plug>unimpairedPut".a:map)
  endif
endfunction

nnoremap <silent> <Plug>unimpairedPutAbove :call <SID>putline('[p', 'Above')<CR>
nnoremap <silent> <Plug>unimpairedPutBelow :call <SID>putline(']p', 'Below')<CR>

call s:map('n', '[p', '<Plug>unimpairedPutAbove')
call s:map('n', ']p', '<Plug>unimpairedPutBelow')
call s:map('n', '>P', ":call <SID>putline('[p', 'Above')<CR>>']", '<silent>')
call s:map('n', '>p', ":call <SID>putline(']p', 'Below')<CR>>']", '<silent>')
call s:map('n', '<P', ":call <SID>putline('[p', 'Above')<CR><']", '<silent>')
call s:map('n', '<p', ":call <SID>putline(']p', 'Below')<CR><']", '<silent>')
call s:map('n', '=P', ":call <SID>putline('[p', 'Above')<CR>=']", '<silent>')
call s:map('n', '=p', ":call <SID>putline(']p', 'Below')<CR>=']", '<silent>')

" }}}1

" vim:set sw=2 sts=2:
