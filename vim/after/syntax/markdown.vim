" Highlight trailing whitespaces.
"
" https://daringfireball.net/projects/markdown/syntax#p
"
" "When you do want to insert a <br /> break tag using Markdown, you end a line
" with two or more spaces, then type return."
"
" https://stackoverflow.com/a/4617156/2277505
highlight ExtraWhitespace ctermbg=00 ctermfg=yellow cterm=underline
syn match ExtraWhitespace /\S\zs\s\{2,\}$/
