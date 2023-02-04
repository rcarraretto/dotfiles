function! KeyboardLayout#ToggleAutoChange() abort
  augroup AutoChangeKeyboardLayout
    autocmd!
  augroup END
  let g:AUTO_CHANGE_KEYBOARD_LAYOUT = g:AUTO_CHANGE_KEYBOARD_LAYOUT ? 0 : 1
  if !g:AUTO_CHANGE_KEYBOARD_LAYOUT
    echom 'Stopped auto change keyboard layout'
    return
  endif
  echom 'Started auto change keyboard layout'
  call KeyboardLayout#AutoChangeOn()
endfunction

function! s:Log(msg) abort
  " Log a:msg
endfunction

function! s:InsertEnter() abort
  call s:Log('InsertEnter')
  let s:in_insert = 1
  call s:ToggleKeyboardLayout('keyboardLayoutInsertEnter')
endfunction

function! s:InsertLeave() abort
  call s:Log('InsertLeave')
  let s:in_insert = 0
  call s:ToggleKeyboardLayout('keyboardLayoutInsertLeave')
endfunction

function! s:CmdlineEnter(afile) abort
  call s:Log('CmdlineEnter ' . a:afile)
  let s:in_search = 1
  if s:in_insert == 0
    " During insert mode, a mapping may trigger a CmdlineEnter + CmdlineLeave.
    " In that case, there should be no keyboard layout switch.
    " Example is 'auto-pairs' plugin which contains 'inoremap's of <cr> and
    " <bs> of form '<c-r>=Func()<cr>'.
    call s:ToggleKeyboardLayout('keyboardLayoutInsertEnter')
  endif
endfunction

function! s:CmdlineLeave(afile) abort
  call s:Log('CmdlineLeave ' . a:afile)
  let s:in_search = 0
  if s:in_insert == 0
    " See comment on s:CmdlineEnter()
    call s:ToggleKeyboardLayout('keyboardLayoutInsertLeave')
  endif
endfunction

" Due to 'terminus', if in insert mode, a cmd+tab will trigger:
" InsertLeave
" FocusLost
" When coming back to vim:
" InsertEnter
" InsertLeave
" FocusGained
" InsertEnter
function! s:FocusGained() abort
  call s:Log('FocusGained')
  if s:in_insert == 0 && s:in_search == 0
    call s:ToggleKeyboardLayout('switchToStandardKeyboardLayout')
  endif
endfunction

function! KeyboardLayout#AutoChangeOn() abort
  augroup AutoChangeKeyboardLayout
    let s:in_insert = 0
    let s:in_search = 0
    autocmd!
    autocmd FocusGained  * call s:FocusGained()
    autocmd InsertEnter  * call s:InsertEnter()
    autocmd InsertLeave  * call s:InsertLeave()
    autocmd CmdlineEnter / call s:CmdlineEnter(expand('<afile>'))
    autocmd CmdlineLeave / call s:CmdlineLeave(expand('<afile>'))
    autocmd CmdlineEnter \? call s:CmdlineEnter(expand('<afile>'))
    autocmd CmdlineLeave \? call s:CmdlineLeave(expand('<afile>'))
  augroup END
endfunction

" Use vim-compatible keyboard layout when in normal mode.
" When in insert mode, switch back to the original keyboard layout.
"
" https://stackoverflow.com/q/10983604/2277505
" Based on https://github.com/ironhouzi/bikey-vim/blob/master/plugin/bikey.vim
"
function! s:ToggleKeyboardLayout(hsFuncName) abort
  if !get(g:, 'AUTO_CHANGE_KEYBOARD_LAYOUT', 1)
    return
  endif
  " If Hammerspoon is off, the command will take too much time to respond
  " and vim will be blocked.
  " In that case, this function can be aborted with Ctrl-C and
  " the feature will be turned off altogether.
  let g:AUTO_CHANGE_KEYBOARD_LAYOUT = 0
  let out = system(printf("hs -c '%s()'", a:hsFuncName))
  call s:Log(a:hsFuncName . ' ' . out)
  if v:shell_error
    echoerr printf('%s: %s', a:hsFuncName, out)
    return
  endif
  let g:AUTO_CHANGE_KEYBOARD_LAYOUT = 1
endfunction
