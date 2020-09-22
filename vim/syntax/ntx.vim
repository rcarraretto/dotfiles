if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "ntx"

syn match ntxDivider "^\s*---.*"
syn match ntxLineComment "^#.*$"
syn match ntxHeader "^##.*"
syn match ntxEndSection "^}}}.*"
syn match ntxString "`[^`]\+`"

hi def link ntxLineComment Function
hi def link ntxDivider Comment
hi def link ntxHeader Keyword
hi def link ntxEndSection Keyword

highlight ntxString cterm=none ctermbg=18 ctermfg=6
