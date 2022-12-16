" Overwrite highlight of 'async' and 'await'.
" In $VIMRUNTIME/syntax/javascript.vim:
" async -> javaScriptReserved
" await -> javaScriptStatement
syntax keyword asyncAwait async await
hi def link asyncAwait Function

" split highlight of: arguments this var let
syn clear javaScriptIdentifier
syn keyword javaScriptIdentifier arguments this
hi! def link javaScriptIdentifier Function
syn keyword javaScriptVar var let
hi def link javaScriptVar Keyword

" Overwrite highlight of 'return'
hi! def link javaScriptStatement Keyword
" try, catch
hi! def link javaScriptException Keyword
" case, default
hi! def link javaScriptLabel Keyword
" for, while
hi! def link javaScriptRepeat Keyword

" Object, RegExp, etc.
hi! def link javaScriptType Function
" null undefined
hi! def link javaScriptNull Constant
" don't highlight ${var} in `hello, ${var}`
hi! def link javaScriptEmbed Normal

" clear: alert confirm prompt status
syn clear javaScriptMessage

" don't highlight 'event'
syn clear javaScriptMember
syn keyword javaScriptMember document location
