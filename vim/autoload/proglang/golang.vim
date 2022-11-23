function! proglang#golang#Config() abort
  " vim-go
  " Remove :GoPlay command, as it uploads code to the internet
  " One could accidentally leak sensitive information
  if exists(':GoPlay')
    delcommand GoPlay
  endif
endfunction

" Adapted version of :GoDoc from vim-go:
" - When the popup is already open, close it
" - Set the popup to close with any cursor move
function! proglang#golang#GoDocToggle() abort
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

function! proglang#golang#PrintCurrentFuncNameGolang() abort
  let winview = winsaveview()
  " go to top of function (vim-go)
  noautocmd normal [[
  let line = getline('.')
  noautocmd execute "normal \<c-o>"
  " fix scroll position that was changed by <c-o>
  call winrestview(winview)
  " Delay the echo.
  " Else calling this function right after switching lines has the side effect
  " of the echo being erased by some other code.
  " Maybe this is related to some plugin using a Cursor autocmd.
  call util#delayed_echo(line)
endfunction
