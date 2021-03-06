" Remove 'await' from branch
syntax clear typescriptBranch
syntax keyword typescriptBranch break continue yield

" Remove 'async' from label
syntax clear typescriptLabel
syntax keyword typescriptLabel case default readonly

" Remove 'parent' from global
syntax clear typescriptGlobal
syntax keyword typescriptGlobal self top

syntax keyword typescriptF async await constructor

hi def link typescriptBranch Conditional
hi def link typescriptLabel Label
hi def link typescriptF Function

" remove highlighting for 'alert confirm prompt status'
syntax clear typescriptMessage
