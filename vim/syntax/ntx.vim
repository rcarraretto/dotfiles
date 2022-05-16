if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "ntx"

syn match ntxDivider "^\s*---.*"
syn match ntxLineComment "^#.*$"
syn match ntxHeader "^##.*"
syn match ntxEndSection "^}}}.*"
syn region ntxCodeBlock start=/^```$/ end=/^```$/
syn match ntxKeyword "|[^| ]\+|" contains=ntxKeywordMark
syn match ntxKeywordMark "|" contained conceal

hi def link ntxLineComment Function
hi def link ntxDivider Comment
hi def link ntxHeader Keyword
hi def link ntxEndSection Keyword

highlight ntxKeyword cterm=none ctermbg=none ctermfg=6
