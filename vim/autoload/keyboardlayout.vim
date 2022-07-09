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

function! KeyboardLayout#AutoChangeOn() abort
  augroup AutoChangeKeyboardLayout
    let s:is_insert_or_search = 0
    autocmd!
    autocmd FocusGained  * if s:is_insert_or_search == 0 | call s:ToggleKeyboardLayout('switchToStandardKeyboardLayout') | endif
    autocmd FocusLost    * call s:ToggleKeyboardLayout('switchToPreviousKeyboardLayout')
    autocmd InsertEnter  * call s:ToggleKeyboardLayout('switchToPreviousKeyboardLayout') | let s:is_insert_or_search = 1
    autocmd InsertLeave  * call s:ToggleKeyboardLayout('switchToStandardKeyboardLayout') | let s:is_insert_or_search = 0
  "   autocmd CmdlineEnter / call s:ToggleKeyboardLayout('switchToPreviousKeyboardLayout') | let s:is_insert_or_search = 1
  "   autocmd CmdlineLeave / call s:ToggleKeyboardLayout('switchToStandardKeyboardLayout') | let s:is_insert_or_search = 0
  "   autocmd CmdlineEnter ? call s:ToggleKeyboardLayout('switchToPreviousKeyboardLayout') | let s:is_insert_or_search = 1
  "   autocmd CmdlineLeave ? call s:ToggleKeyboardLayout('switchToStandardKeyboardLayout') | let s:is_insert_or_search = 0
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
  if v:shell_error
    echoerr printf('%s: %s', a:hsFuncName, out)
    return
  endif
  let g:AUTO_CHANGE_KEYBOARD_LAYOUT = 1
endfunction
