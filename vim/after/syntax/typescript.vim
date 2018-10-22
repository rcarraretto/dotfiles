" Remove 'await' from branch
syn clear typescriptBranch
syntax keyword typescriptBranch break continue yield

" Remove 'async' from label
syn clear typescriptLabel
syntax keyword typescriptLabel case default readonly

syntax keyword typescriptAA async await

hi def link typescriptBranch Conditional
hi def link typescriptLabel Label
hi def link typescriptAA Function
