" Highlight for template string (e.g. `Hello, ${name}`)
" Adapted from https://github.com/jelera/vim-javascript-syntax
syntax region javaScriptTemplateString start=+`+ skip=+\\\(`\|$\)+ end=+`+ keepend
hi def link javaScriptTemplateString String

" Overwrite highlight of 'return'
hi def link javaScriptStatement Keyword

" Add highlight for 'async' and 'await'
syntax keyword asyncAwait async await
hi def link asyncAwait Function
