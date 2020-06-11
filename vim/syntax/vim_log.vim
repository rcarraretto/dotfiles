if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "vim_log"

syn match vlTimestamp "^\[\d\+\d\+:\d\+\d\+:\d\+\d\+\]"

highlight vlTimestamp ctermfg=08 ctermbg=00
