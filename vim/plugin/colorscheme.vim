if !exists('$COLORTERM')
  " fix base16 colors when inside Intellij terminal
  " https://github.com/chriskempson/base16-vim#troubleshooting
  set termguicolors
endif

function! s:SetHighlight() abort
  " Remove underline from cursor line number
  " https://stackoverflow.com/a/58181112/2277505
  highlight CursorLineNr cterm=bold

  " Override base16-vim Search highlight
  " Simply add underline, instead of changing fg and bg
  highlight Search ctermbg=none ctermfg=none cterm=underline
  " Don't use different bg when Folded
  highlight Folded ctermbg=00

  " Change error style.
  " :h attr-list
  " e.g., error gutter
  highlight Error ctermfg=red ctermbg=00 cterm=reverse
  " e.g., typescript syntax error
  highlight SpellBad ctermfg=NONE ctermbg=NONE cterm=underline

  " Change base syntax highlighting
  "
  " e.g., vim 'highlight', 'endif', etc.
  " in base16-ocean, change from red to purple
  highlight Statement ctermfg=5
  "
  " e.g., vim variables
  " in base16-ocean, change from red to white
  highlight Identifier NONE
  "
  " e.g., vim parentheses
  " in base16-ocean, change from brown to white
  highlight Delimiter NONE
  " unlink Delimiter from Special
  highlight link Delimiter NONE

  " indirectly change markdownBold
  " in base16-ocean, change from yellow to green
  highlight htmlBold NONE
  highlight link htmlBold Special

  " e.g., Golang rune and byte
  " in base16-ocean, change from red to green
  highlight! def link Character Special

  " Customize highlight from 'parenmatch' plugin.
  " Basically copy MatchParen highlight from the standard 'matchparen' plugin.
  highlight ParenMatch term=reverse ctermbg=8

  " color agit diff similar to vim's git diff syntax
  " $VIM/vim81/syntax/git.vim
  highlight def link agitDiffAdd diffAdded
  highlight def link agitDiffRemove diffRemoved

  " Customize YouCompleteMe highlight of warnings (e.g., java)
  highlight YcmWarningSection cterm=undercurl ctermbg=none

  " Customize vim-bookmarks
  highlight BookmarkSign ctermbg=18 ctermfg=8
  highlight BookmarkAnnotationSign ctermbg=18 ctermfg=8
endfunction

" Custom highlights are lost when :colorscheme is executed.
" Therefore, one must listen to 'ColorScheme' events,
" instead of executing :highlight commands directly.
"
" https://github.com/chriskempson/base16-vim#customization
"
" This autocmd is set up before the :colorscheme is set,
" so that s:SetHighlight() gets called when vim loads.
augroup SetHighlight
  autocmd!
  " This is triggered by both:
  " - set background=<value> (apparently only after a colorscheme has been set)
  " - colorscheme <name>
  autocmd ColorScheme * call s:SetHighlight()
augroup END

" This block has to come after SetHighlight augroup is defined,
" so :colorscheme triggers s:SetHighlight().
if !exists('g:colors_name')
  " Only set the background on the first load.
  " Else, when re-sourcing the script, both ':set background' and ':colorscheme'
  " would trigger the ColorScheme event unnecessarily.
  set background=dark
  " Only set :colorscheme on the first load of script.
  " Else, when re-sourcing the script, syntax highlighting would be reset
  " but 'after/syntax' blocks would not execute,
  " therefore disabling custom 'after/syntax' blocks.
  if exists('$BASE16_THEME')
    try
      " base16-vim plugin config:
      " Access colors present in 256 colorspace
      " https://github.com/chriskempson/base16-vim#256-colorspace
      let base16colorspace=256
      colorscheme base16-$BASE16_THEME
    catch /^Vim\%((\a\+)\)\=:E185/
      " Don't fail if base16-vim plugin is not installed
    endtry
  endif
endif
