if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "ntx"

" reduce ambiguity with multiple ``` blocks
syntax sync minlines=100

syn match ntxDivider "^\s*---.*"
syn match ntxLineComment "^#\(\s.\+\)\?$"
syn match ntxHeader "^##.*"
syn match ntxEndSection "^}}}.*"
syn region ntxCodeBlock start=/^```$/ end=/^```$/

hi def link ntxLineComment Function
hi def link ntxDivider Comment
hi def link ntxHeader Keyword
hi def link ntxEndSection Keyword
hi def link ntxCodeBlock Special
