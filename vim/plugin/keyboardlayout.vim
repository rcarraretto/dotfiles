if !executable('hs') || !exists('g:AUTO_CHANGE_KEYBOARD_LAYOUT')
  let g:AUTO_CHANGE_KEYBOARD_LAYOUT = 0
endif

command! ToggleAutoChangeKeyboardLayout call KeyboardLayout#ToggleAutoChange()

augroup TurnOnAutoChangeKeyboardLayout
  autocmd!
  autocmd VimEnter * if g:AUTO_CHANGE_KEYBOARD_LAYOUT == 1 | call KeyboardLayout#AutoChangeOn() | endif
augroup END
