" Adapted from https://github.com/jelera/vim-javascript-syntax

syntax region javaScriptTemplateString start=+`+  skip=+\\\(`\|$\)+  end=+`+ keepend

hi def link javaScriptTemplateString String

syntax keyword asyncAwait async await
hi def link asyncAwait Function
