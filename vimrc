" Plugins ---------------------- {{{

set rtp+=$BREW_PREFIX/opt/fzf

if exists('$DOTFILES_PRIVATE') && isdirectory($DOTFILES_PRIVATE . '/vim')
  set rtp+=$DOTFILES_PRIVATE/vim
endif

if exists('$DOTFILES_HOME') && isdirectory($DOTFILES_HOME . '/vim')
  set rtp+=$DOTFILES_HOME/vim
endif

if exists('$DOTFILES_WORK') && isdirectory($DOTFILES_WORK . '/vim')
  set rtp+=$DOTFILES_WORK/vim
endif

call plug#begin('~/.vim/bundle')

Plug 'junegunn/vim-plug'

" >>> Color scheme <<<
Plug 'danielwe/base16-vim', { 'commit': '4533d1ccab2483deabc743e51321d29a259a819e' }

" >>> Search <<<
Plug 'junegunn/fzf.vim', { 'commit': 'e393108bfae7ab308aa6ea38e0df19253cdc8499' }

" >>> Text editing (Part 1) <<<
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'rcarraretto/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'SirVer/ultisnips', { 'commit': '423f264e753cec260b4f14455126e6db7ba429af' }
if !has('nvim')
  Plug 'Valloric/YouCompleteMe', { 'commit': '4df6f35f0c9f9aec21a3f567397496b5dee6acc7' }
endif
Plug 'AndrewRadev/splitjoin.vim'

" >>> Support <<<
Plug 'tpope/vim-dispatch', { 'commit': '00e77d90452e3c710014b26dc61ea919bc895e92' }
" focus reporting
Plug 'wincent/terminus', { 'commit': '340ea44dfec58c9d48e46c97c90896ed04e2a264' }
" file system commands
Plug 'tpope/vim-eunuch'
" git
Plug 'tpope/vim-fugitive', { 'commit': '194d63da4f7111c156109375e8ca153f19b245cb' }
" github support for fugitive
Plug 'tpope/vim-rhubarb'
" gitlab support for fugitive
Plug 'shumphrey/fugitive-gitlab.vim'
" debugging vim / vimscript
Plug 'tpope/vim-scriptease', { 'commit': '386f19cd92f7b30cd830784ae22ebbe7033564aa' }
" directory viewer (replaces netrw)
if !$USE_NETRW
  Plug 'justinmk/vim-dirvish', { 'commit': 'f297b2effb0ec879f33a8539b9701d048d44f295' }
endif

" highlight matching parentheses.
" alternative to the standard 'matchparen' plugin.
" it offers the ability to toggle highlighting per buffer.
Plug 'rcarraretto/vim-parenmatch'
" disable the standard 'matchparen' plugin
" to use the 'parenmatch' plugin instead
let g:loaded_matchparen = 1
let g:parenmatch_highlight = 0

" >>> Text Objects <<<
Plug 'kana/vim-textobj-user'
" indent: ai
Plug 'kana/vim-textobj-indent'
" fold: az
Plug 'kana/vim-textobj-fold'
" quotes: aq / iq
Plug 'beloglazov/vim-textobj-quotes'
" variable segment: av / iv
" e.g. seg_seg_seg, SegSegSeg
Plug 'Julian/vim-textobj-variable-segment'
" function arguments: aa / ia
Plug 'vim-scripts/argtextobj.vim'

" >>> Text editing (Part 2) <<<
" indentation
Plug 'tpope/vim-sleuth'
" change word casing, case-aware substitute
Plug 'tpope/vim-abolish'
" readline style for command line mode and insert mode
Plug 'tpope/vim-rsi'
Plug 'junegunn/vim-easy-align'

" >>> Language specific <<<
" Typescript
Plug 'leafgarland/typescript-vim', {
      \'for': ['javascript', 'typescript', 'typescript.tsx'],
      \'commit': '09cf6a6ecdef11cd32d38213093cfe86660255aa' }
Plug 'Quramy/tsuquyomi', {
      \'for': ['javascript', 'typescript', 'typescript.tsx'],
      \'commit': '785af7476e0db2522372ef585c86947fc5625c81' }
Plug 'peitalin/vim-jsx-typescript', {
      \'for': ['javascript', 'typescript', 'typescript.tsx'],
      \'commit': '07370d48c605ec027543b52762930165b1b27779' }
" Python
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" Golang
Plug 'fatih/vim-go', {
      \'for': 'go',
      \'do': ':GoUpdateBinaries',
      \'commit': '2855115efb1dd8a5f4436a80138633a1cb5d9f0c' }
" Terraform
Plug 'hashivim/vim-terraform', {
      \'for': 'terraform',
      \'commit': '9166d42e5dc9bc0ef7e1b9e93d52bb4c5b923560' }
" Applescript
Plug 'vim-scripts/applescript.vim', {
      \'for': 'applescript',
      \'commit': '00840b4059c7884120913907f4778092edb006f7' }

" >>> Used occasionally <<<
if $USE_VIM_BOOKMARKS
  " Add bookmarks to buffer via 'signs' feature
  Plug 'MattesGroeger/vim-bookmarks', {
        \'commit': '9cc5fa7ecc23b052bd524d07c85356c64b92aeef' }
endif
" Git log viewer
" Plug 'cohama/agit.vim'
" Handlebars
" Plug 'mustache/vim-mustache-handlebars'
" Elixir
" Plug 'elixir-lang/vim-elixir'

call plug#end()

" }}}

" Settings ---------------------- {{{

set number
set relativenumber
set history=1000
set ruler
set showcmd		" display incomplete commands
set incsearch
set backupdir=~/.tmp-vim
" backupcopy
"
" Cope with webpack watch mode.
" https://webpack.js.org/guides/development/#adjusting-your-text-editor
"
" "yes": make a copy of the file and overwrite the original one
"   - preserves inode
"   - slower than "no"
"
" "no": rename the file and write a new one
"   - changes inode
"   - messes up symbolic links
"   - faster than "yes"
"
" "auto": will use "no" if no side effects, else will use "yes"
"
" To test this, inspect the inode before and after saving a file:
" ls -i path/to/file
" https://vi.stackexchange.com/a/138/24815
set backupcopy=yes
set directory=~/.tmp-vim
set hlsearch
set smartcase
set ignorecase
set autoindent
set nowrap
" Use system clipboard as vim's default clipboard
set clipboard=unnamed

" when the last line is too large (may happen when using 'wrap'),
" show as much as possible, instead of showing @'s
" https://vi.stackexchange.com/a/103
set display+=lastline

set linebreak
set scrolloff=3
set hidden
set laststatus=2 " always display status line
set t_Co=256
set noeb vb t_vb=
set completeopt=menu
set wildmenu
set splitright
set splitbelow
set formatoptions-=cro
set synmaxcol=1000
set backspace=indent,eol,start
set encoding=utf-8
set listchars=tab:>\ ,space:␣
set tabstop=2
set shiftwidth=2
set expandtab

set shortmess+=A " no warning for existing swap file

" "save and restore global variables that start with an uppercase letter, and
" don't contain a lowercase letter"
" :h viminfo-!
set viminfo+=!


" Load aliases for executing shell commands within vim
let $BASH_ENV = "~/.bash_aliases"

function! s:SetHighlight() abort
  " Remove underline from cursor line number
  " https://stackoverflow.com/a/58181112/2277505
  highlight CursorLineNr cterm=bold

  " Override base16-default-dark Search highlight
  " Simply add underline, instead of changing fg and bg
  highlight Search ctermbg=none ctermfg=none cterm=underline,bold
  " Don't use different bg when Folded
  highlight Folded ctermbg=00

  " Change error style.
  " :h attr-list
  " e.g., error gutter
  highlight Error ctermfg=red ctermbg=00 cterm=reverse
  " e.g., error in some vim setting
  highlight vimError ctermfg=red ctermbg=NONE cterm=underline
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
  highlight Identifier none
  "
  " e.g., vim parentheses
  " in base16-ocean, change from brown to white
  highlight Delimiter none
  " unlink Delimiter from Special
  highlight link Delimiter NONE

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
" instead of executing :highlight commands directly in the vimrc.
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

if !exists('g:colors_name')
  " Only set the background on the first load of vimrc.
  " Else, when re-sourcing the vimrc, both ':set background' and ':colorscheme'
  " would trigger the ColorScheme event unnecessarily.
  set background=dark
  " Only set :colorscheme on the first load of vimrc.
  " Else, when re-sourcing the vimrc, syntax highlighting would be reset
  " but 'after/syntax' blocks would not execute,
  " therefore disabling custom 'after/syntax' blocks.
  try
    " base16-vim plugin config:
    " Access colors present in 256 colorspace
    " https://github.com/chriskempson/base16-vim#256-colorspace
    let base16colorspace=256
    colorscheme base16-default-dark
  catch /^Vim\%((\a\+)\)\=:E185/
    " Don't fail if base16-vim plugin is not installed
  endtry
endif

" }}}

" Auto commands ---------------------- {{{

augroup FTOptions
  autocmd!
  " iskeyword => easier search in 'someplugin#somefunc'
  autocmd FileType vim setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
        \| setlocal foldlevel=20
        \| setlocal textwidth=0
        \| setlocal iskeyword-=#
  autocmd FileType sh setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType text setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType markdown setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  " my own personal notes format
  autocmd FileType ntx setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
    \| setlocal foldmethod=marker
    \| setlocal commentstring=#\ %s
    \| setlocal nocursorline | let b:skip_cursor_line=1
    \| setlocal conceallevel=2 concealcursor=nvc
  autocmd FileType javascript,typescript,typescript.tsx setlocal foldmethod=indent | setlocal foldlevel=20 | setlocal formatoptions-=cro
  autocmd FileType typescript.tsx setlocal commentstring=//\ %s
  autocmd FileType html,xhtml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType json setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType yaml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType xml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType lua setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType ruby setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldlevel=20
  autocmd FileType c,cpp setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType go setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType php setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal foldmethod=indent | setlocal foldlevel=1
  autocmd FileType graphql setlocal shiftwidth=4 | setlocal tabstop=4 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType applescript setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal commentstring=--\ %s
  " Avoid "crontab: temp file must be edited in place".
  " https://vi.stackexchange.com/a/138/24815
  autocmd FileType crontab setlocal backupcopy=yes
  autocmd FileType haskell setlocal expandtab
  autocmd FileType matlab setlocal commentstring=%\ %s
  autocmd FileType pem setlocal foldmethod=marker | setlocal foldmarker=-----BEGIN,-----END | setlocal foldlevel=20
augroup END

augroup SetFiletype
  autocmd!
  autocmd BufNewFile,BufRead .luacheckrc set filetype=lua
  autocmd BufNewFile,BufRead .ignore set filetype=conf
  autocmd BufNewFile,BufRead *.applescript set filetype=applescript
  autocmd BufNewFile,BufRead *.jenkinsfile set filetype=groovy
  autocmd BufNewFile,BufRead Dockerfile.* set filetype=Dockerfile
  autocmd BufNewFile,BufRead *.pem,*.crt,*.key,*.csr set filetype=pem
  " filetype 'dosini' seems to highlight better than 'conf',
  " as it highlights keys and values differently.
  autocmd BufNewFile,BufRead *.conf set filetype=dosini | setlocal commentstring=#\ %s
  " The /Volumes/GoogleDrive pattern accounts for GDrive in "stream mode".
  " If $NOTES starts with "$HOME/Google\ Drive", this is actually a symlink to
  " /Volumes/GoogleDrive-\d+.
  " When running :Ag, the quickfix list is populated with the real path, so the
  " $NOTES autocmd-pattern end up not matching (I think).
  autocmd BufNewFile,BufRead $NOTES_SHARED/*.txt,
    \$NOTES_HOME/*.txt,
    \$NOTES_WORK/*.txt,
    \/Volumes/GoogleDrive[^/]\\\{0,\}/My\ Drive/notes-*.txt,
    \.todo
    \ set ft=ntx
augroup END

augroup SpecialFiles
  autocmd!
  " Apparently Karabiner likes to save this file without an EOL
  autocmd BufRead ~/.config/karabiner/karabiner.json setlocal nofixendofline
  autocmd BufRead ~/work/dotfiles/karabiner/*/karabiner.json setlocal nofixendofline
  " Approximate highlight for aws conf files
  " https://stackoverflow.com/a/16338432/2277505
  autocmd BufRead ~/.aws/credentials,~/.aws/config set filetype=dosini | setlocal commentstring=#\ %s
augroup END

" }}}

" Plugin settings ---------------------- {{{

if has('nvim')
  let g:python3_host_prog = $BREW_PREFIX . '/bin/python3'
endif

" fzf
" extend actions with mapping to open in system editor
let g:fzf_action = {
\ '': 'silent edit ',
\ 'ctrl-t': 'silent tab split',
\ 'ctrl-x': 'silent split',
\ 'ctrl-v': 'silent vsplit',
\ 'ctrl-f': 'silent VSplitLeft',
\ 'ctrl-s': 'SysOpen'
\ }
" use a normal window at the bottom
" (else by default it opens a popup window in the center, which seems more laggy)
let g:fzf_layout = { 'down': '40%' }

" Dispatch
let g:dispatch_no_maps = 1
let g:dispatch_tmux_height = 3

" Terminus
let g:TerminusCursorShape = 0
" attempt to fix issue with 'paste' being toggled on automatically.
" similar issue to:
" https://www.reddit.com/r/vim/comments/9uerhp/disable_insert_paste_mode/
let g:TerminusBracketedPaste = 0

" Pymode
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 300
let g:pymode_options_colorcolumn = 0
let g:pymode_run = 0

" UltiSnips
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<c-b>"
let g:UltiSnipsJumpBackwardTrigger = "<c-z>"
let g:UltiSnipsSnippetsDir = "~/.vim/UltiSnips"

" YouCompleteMe
let g:ycm_key_list_select_completion = ['<Enter>']
if exists('$DISABLE_YCM_C_LANG')
  let g:ycm_filetype_specific_completion_to_disable = {
  \ 'c': 1,
  \ 'cpp': 1
  \ }
endif
let g:ycm_always_populate_location_list = 1
" disable documentation popup
" (used by Golang)
let g:ycm_auto_hover = ''
" disable Golang warning
let g:ycm_filter_diagnostics = {
\   "go": {
\     "regex": ["composite literal uses unkeyed fields"],
\   }
\ }

" EasyAlign
" e: elixir
let g:easy_align_delimiters = {
\ 'e': { 'pattern': '->\|do:' }
\ }

" Tsuquyomi
let g:tsuquyomi_disable_quickfix = 1
let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_single_quote_import = 1
" properly import from frameworks, like typeorm.
"
" import { Repository } from 'typeorm/repository/Repository';
" =>
" import { Repository } from 'typeorm';
let g:tsuquyomi_shortest_import_path = 1

" Golang
" remove syntax highlight of trailing whitespace as red
" $VIMRUNTIME/syntax/go.vim:44:9
" https://stackoverflow.com/a/40945424
let g:go_highlight_trailing_whitespace_error = 0

" vim-go
" don't call :GoFmt on save
let g:go_fmt_autosave = 0
" fix imports on save
let g:go_imports_autosave = 1
" use popup for :GoDoc
let g:go_doc_popup_window = 1
" don't add K as :GoDoc mapping.
" K is mapped to s:GoDocToggle instead
let g:go_doc_keywordprg_enabled = 0
" disable snippets shipped with the plugin
let g:go_snippet_engine = ''
" use quickfix list, instead of location list
let g:go_list_type = "quickfix"

" Colorizer
" keep buffer colorized when you leave it
let g:colorizer_disable_bufleave = 1

" vim-bookmarks
let g:bookmark_no_default_key_mappings = 1
let g:bookmark_sign = '•'
" perf: add on demand as it uses a CursorMoved autocmd
" let g:bookmark_display_annotation = 1

" }}}

" vim: set foldmethod=marker foldlevel=0:
