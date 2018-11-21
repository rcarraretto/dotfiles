" Remove 'await' from branch
syn clear typescriptBranch
syntax keyword typescriptBranch break continue yield

" Remove 'async' from label
syn clear typescriptLabel
syntax keyword typescriptLabel case default readonly

syntax keyword typescriptF async await constructor

hi def link typescriptBranch Conditional
hi def link typescriptLabel Label
hi def link typescriptF Function

" remove highlighting for 'alert confirm prompt status'
syntax clear typescriptMessage
