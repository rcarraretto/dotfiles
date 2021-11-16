"# vim: set foldmethod=marker:

" Plugins ---------------------- {{{
set rtp+=/usr/local/opt/fzf

if exists('$DOTFILES_PRIVATE') && isdirectory($DOTFILES_PRIVATE . '/vim')
  set rtp+=$DOTFILES_PRIVATE/vim
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
Plug 'Valloric/YouCompleteMe', { 'commit': '4df6f35f0c9f9aec21a3f567397496b5dee6acc7' }
Plug 'AndrewRadev/splitjoin.vim'

" >>> Support <<<
Plug 'tpope/vim-dispatch'
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
      \'commit': '22df470d92651426f2377e3166488672f7b4b4ef' }
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
" Git log viewer
" Plug 'cohama/agit.vim'
" Handlebars
" Plug 'mustache/vim-mustache-handlebars'
" Kotlin
" Plug 'udalov/kotlin-vim'
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

  " Customize highlight from 'parenmatch' plugin.
  " Basically copy MatchParen highlight from the standard 'matchparen' plugin.
  highlight ParenMatch term=reverse ctermbg=8

  " color agit diff similar to vim's git diff syntax
  " $VIM/vim81/syntax/git.vim
  highlight def link agitDiffAdd diffAdded
  highlight def link agitDiffRemove diffRemoved

  " Customize YouCompleteMe highlight of warnings (e.g., java)
  highlight YcmWarningSection cterm=undercurl ctermbg=none
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
        \| setlocal textwidth=0
        \| setlocal iskeyword-=#
        \| call s:VimscriptMappings()
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
  autocmd FileType json setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType yaml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType xml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType lua setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType ruby setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldlevel=20
  autocmd FileType c,cpp setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType go setlocal foldmethod=indent | setlocal foldlevel=20 | call proglang#GolangMappings()
  autocmd FileType php setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal foldmethod=indent | setlocal foldlevel=1
  autocmd FileType graphql setlocal shiftwidth=4 | setlocal tabstop=4 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType applescript setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal commentstring=--\ %s
  " Avoid "crontab: temp file must be edited in place".
  " https://vi.stackexchange.com/a/138/24815
  autocmd FileType crontab setlocal backupcopy=yes
  autocmd FileType haskell setlocal expandtab
  autocmd FileType matlab setlocal commentstring=%\ %s
  autocmd FileType agit call s:AgitConfig()
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

augroup CmdlineWinMapping
  autocmd!
  " Because I remapped <cr> in normal mode (nnoremap <cr> :),
  " <cr> in cmdline window no longer executes the cmd under cursor.
  " put this behavior back
  autocmd CmdwinEnter * nnoremap <buffer> <cr> <cr>
augroup END

augroup QuickfixMapping
  autocmd!
  " Because I remapped <cr> in normal mode (nnoremap <cr> :),
  " On quickfix, make 'o' open the target line
  autocmd BufReadPost quickfix nnoremap <buffer> o <cr>
augroup END

augroup FugitiveMapping
  autocmd BufEnter * call s:FugitiveMappings()
augroup END

augroup OverridePluginMappings
  autocmd!
  autocmd VimEnter * call s:OverridePluginMappings()
augroup END

" }}}

" Functions ---------------------- {{{

function! s:OverridePluginMappings()
  " Revert plugin side effects
  " rsi.vim
  if !empty(maparg("<c-f>", "c", 0, 1))
    cunmap <c-f>
  endif
  " rsi.vim
  " ä ('a' umlaut)
  " https://github.com/tpope/vim-rsi/issues/14
  if !empty(maparg("<M-d>", "i", 0, 1))
    iunmap <M-d>
  endif
endfunction

function! s:VimscriptMappings() abort
  nnoremap <buffer> <leader>ss :silent update <bar> call vimutil#DisarmPluginGuard() <bar> source %<cr>
endfunction

function! s:AgitConfig()
  let mapping = maparg("<cr>", "n", 0, 1)
  if empty(mapping) || !mapping['buffer']
    " if there is no nmap <buffer> <cr>,
    " then this function was already executed
    return
  endif
  " keep <cr> as it normally is (nnoremap <cr> :)
  nunmap <buffer> <cr>
  " map 'o' to what <cr> is in Agit (open commit)
  nnoremap <buffer> o <Plug>(agit-show-commit)
endfunction

function! s:FugitiveMappings()
  if !exists('b:fugitive_type')
    return
  endif
  if exists('b:mapping_fugitive_cr')
    return
  endif
  let mapping = maparg("<cr>", "n", 0, 1)
  if empty(mapping) || !mapping['buffer']
    return
  endif
  " e.g. ':<C-U>exe <SID>BlameCommit("exe ''norm q''<Bar>edit")<CR>
  let b:mapping_fugitive_cr = substitute(maparg("<cr>", "n"), "|", "<bar>", 'g')
  " map 'o' to what <cr> is in fugitive (open file in existing window)
  execute "nnoremap <buffer> <silent> o " . b:mapping_fugitive_cr
  " unmap <cr> for fugitive buffer,
  " which will make <cr> fallback to global behavior, i.e.,
  " nnoremap <cr> :
  nunmap <buffer> <cr>
endfunction

function! RefreshChrome()
  silent exec "!osascript $HOME/.applescript/refresh-chrome.applescript"
  redraw!
  return 0
endfunction

"}}}

" Mappings ---------------------- {{{

" Exit insert mode
inoremap jk <esc>

" j + k: move through 'display lines'
" <c-j> + <c-k>: move through 'lines'
" Store relative line number jumps in the jumplist if they exceed a threshold.
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : '') . 'gj'
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : '') . 'gk'
nnoremap <c-k> k
vnoremap j gj
vnoremap k gk
vnoremap <c-j> j
vnoremap <c-k> k

" Easier command-line mode
nnoremap <cr> :
xnoremap <cr> :

" Copy until the end of line.
" Make Y consistent with C and D.
nnoremap Y y$

" Stop highlighting
nnoremap <silent> gh :noh<cr>

" Save
nnoremap <c-l> <esc>:silent write<cr>
inoremap <c-l> <esc>:silent write<cr>

" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN

" Search in file (from visual mode)
xnoremap * :<c-u>call search#VisualStar('/')<cr>/<c-r>=@/<cr><cr>
xnoremap # :<c-u>call search#VisualStar('?')<cr>?<c-r>=@/<cr><cr>

" Show output of last command
nnoremap K :!<cr>

" Move between paragraphs.
" Similar to vim's { and }, but jumps to the first line of paragraph,
" instead of to an empty line.
nnoremap <silent> { :call viewing#MoveToPrevParagraph()<cr>
nnoremap <silent> } :call viewing#MoveToNextParagraph()<cr>

" Move between folds
" 'zj' moves downwards to the start of the next fold
" Update 'zk' to move upwards to the start of the previous fold
nnoremap zk zk[z

" Use <tab> to toggle folding.
" On Karabiner Elements, <c-i> will send <f6>
" to avoid collision between <tab> and <c-i>.
"
" Requires macOS keyboard setting:
" 'Use F1, F2, etc. keys as standard function keys'
"
" Taken from https://github.com/wincent/wincent
nnoremap <silent> <tab> :call folding#Toggle()<cr>
nnoremap <f6> <c-i>

" Reset foldlevel to 1
nnoremap <silent> zf :call folding#ResetFoldLevel()<cr>
" Print the name of the current function
nnoremap <silent> zp :call proglang#PrintCurrentFuncName()<cr>

" Swap single quote and backtick
nnoremap ' `
vnoremap ' `
onoremap ' `
nnoremap ` '
vnoremap ` '
onoremap ` '

" Edit the alternate file
nnoremap <leader><leader> <c-^>

" Quotes textobj
omap q iq

" Toggle relative number
nnoremap <silent> con :call viewing#ToggleRelativeNumber()<cr>
" Toggle showing whitespace
nnoremap <silent> col :call viewing#ToggleListChars()<cr>
" Toggle showing extended info in statusline
nnoremap <silent> cos :call util#ToggleGlobalVar('statusline_show_ext_info')<cr>
" Toggle color column
nnoremap <silent> coc :call util#ToggleBufVar('&colorcolumn', {'print': 1, 'on_value': '80,100'})<cr>
" Toggle cursor column
nnoremap <silent> cox :call util#ToggleBufVar('&cursorcolumn', {'print': 1})<cr>
" Toggle trim whitespace
command! ToggleTrimWhitespace :call util#ToggleBufVar('skip_trim_whitespace', {'print': 1})
" Toggle conceal
command! ToggleConceal :call util#ToggleBufVar('&conceallevel', {'print': 1, 'off_value': '0', 'on_value': '3'})

" Windows
" window navigation
nnoremap <silent> <space>j :call window#CycleWinDownOrNext()<cr>
nnoremap <silent> <space>k :call window#CycleWinUpOrPrev()<cr>
nnoremap <silent> <space>h :call window#CycleWinLeft()<cr>
nnoremap <silent> <space>l :call window#CycleWinRight()<cr>
nnoremap <space>; <c-w>p
nnoremap <space>w <c-w><c-w>
" close window
nnoremap <space>q :call window#CloseWindow()<cr>
nnoremap <space>Q :bd!<cr>
" decrease window size
nnoremap <space>, :20wincmd <<cr>
" increase window size
nnoremap <space>. :20wincmd ><cr>
" toggle window size (maximize / make even)
nnoremap <leader>ww :call window#ToggleWindowSize()<cr>

" Quickfix
nnoremap <silent> <space>i :call ToggleQuickfixList()<cr>
nnoremap <silent> <space>I :call ToggleLocationList()<cr>
nnoremap [g :colder<cr>
nnoremap ]g :cnewer<cr>
nnoremap <leader>da :AbortDispatch<cr>

" Tab navigation
nnoremap <silent> [r :tabprevious<cr>
nnoremap <silent> ]r :tabnext<cr>
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>tc :call window#CloseTab()<cr>
nnoremap <leader>th :tabm -1<cr>
nnoremap <leader>tl :tabm +1<cr>

" Command-line history
cnoremap <c-p> <up>
cnoremap <c-n> <down>
cnoremap <c-h> <c-p>
cnoremap <c-l> <c-n>
" Copy current command-line
cnoremap <expr> <c-x>y vimutil#CopyCmdline()

" Browse files/folders & global search
" ---
" browse files
nnoremap <space>o :WrapCommand Files<cr>
" browse files under version control
nnoremap <space>O :GFiles<cr>
" search in project
nnoremap <space>a :Ag --hidden -Q -- ''<left>
" search in git root
nnoremap <space>A :SearchInGitRoot<space>
" grep operator
nnoremap <space>g :set operatorfunc=ag#GrepOperator<cr>g@
vnoremap <space>g :<c-u>call ag#GrepOperator(visualmode())<cr>
nnoremap <space>G :set operatorfunc=ag#GrepOperatorInGitRoot<cr>g@
vnoremap <space>G :<c-u>call ag#GrepOperatorInGitRoot(visualmode())<cr>
" search in dotfiles
nnoremap <leader>ad :SearchDotfiles<space>
" browse dotfiles
nnoremap <leader>od :call fzfutil#FzfDotfiles()<cr>
" search in notes
nnoremap <leader>an :SearchNotes<space>
" browse notes
nnoremap <leader>en :<c-u>call fzfutil#FzfNotes(0)<cr>
nnoremap <leader>eN :<c-u>call fzfutil#FzfNotes(1)<cr>
" browse projects
nnoremap <leader>ep :call fzfutil#FzfExploreProject()<cr>
" browse history
nnoremap <space>m :WrapCommand History<cr>
" browse /var/tmp
nnoremap <leader>ot :Files /var/tmp<cr>
" browse Downloads, most recent first
nnoremap <leader>ol :call fzf#run(fzf#wrap({'source': 'ls -dt ~/Downloads/*'}))<cr>
" browse commands
" (<c-x> executes the command directly)
nnoremap <space>c :Commands<cr>
" browse command-line history
nnoremap <space>: :History:<cr>
" browse current folder (non-recursive)
nnoremap <leader>of :call fzfutil#FzfCurrentFolderNonRecursive(expand("%:h"))<cr>
" browse node_modules
nnoremap <leader>eM :call fzfutil#FzfExploreNodeModules()<cr>
" browse source code of vim plugins
nnoremap <leader>ob :Files ~/.vim/bundle<cr>

" Change directory
nnoremap <silent> <leader>cg :call cwd#CdToGitRoot('lcd')<cr>
nnoremap <silent> <leader>cG :call cwd#CdToGitRoot('cd')<cr>
nnoremap <silent> <leader>cn :call cwd#CdToNodeJsRoot('lcd')<cr>
nnoremap <silent> <leader>cN :call cwd#CdToNodeJsRoot('cd')<cr>
nnoremap <silent> <leader>cb :call cwd#CdToBufferDir('lcd')<cr>
nnoremap <silent> <leader>cB :call cwd#CdToBufferDir('cd')<cr>
" change to previous current directory
nnoremap <silent> <leader>cc :cd - <bar> pwd<cr>

" Edit special files
nnoremap <leader>ei :<c-u>call window#EditFile("~/Dropbox/notes/dev/backlog.txt")<cr>
if exists('$NOTES_WORK') && isdirectory($NOTES_WORK)
  nnoremap <leader>ew :<c-u>call window#EditFile($NOTES_WORK . "/work-backlog.txt")<cr>
endif
" toggle log windows
nnoremap <leader>2 :call vimutil#ToggleLogWindow('/var/tmp/test-console.txt')<cr>
nnoremap <leader>3 :call vimutil#ToggleLogWindow('/var/tmp/test-results.txt')<cr>
nnoremap <leader>4 :call vimutil#ToggleLogWindow('/var/tmp/vim-messages.txt')<cr>
" close auxiliary buffers
nnoremap <leader>ca :call vimutil#CloseAuxiliaryBuffers()<cr>
"
nnoremap <leader>ess :<c-u>call <sid>MaybeSplit() <bar> UltiSnipsEdit<cr>
nnoremap <leader>esp :e $DOTFILES_PRIVATE/vim/UltiSnips/<c-r>=&filetype<cr>.snippets<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :<c-u>call window#EditFileUpwards(".todo")<cr>
nnoremap <leader>em :<c-u>call window#EditFile($DOTFILES_PRIVATE . '/README.md')<cr>
nnoremap <leader>eb :<c-u>call window#EditFile($DOTFILES_PRIVATE . '/bashrc.private')<cr>
" open sketch buffer for current programming language
nnoremap <leader>ek :call proglang#EditSketchBuffer(&ft)<cr>
" edit corresponding test or source file
nnoremap <leader>et :call proglang#EditTestFile()<cr>

" Vimscript, vim debug
nnoremap <leader>ev :<c-u>call window#EditFile(resolve($MYVIMRC))<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>el :<c-u>call window#EditFile($DOTFILES_PRIVATE . '/vim/plugin/private.vim')<cr>
" :Log {expr}
nnoremap <space>v :Log<space>
" reload syntax highlighting
nnoremap <leader>sy :syntax clear <bar> syntax on<cr>
nnoremap <silent> <leader>zS :call vimutil#DebugSynStack()<cr>
" capture :messages in a file
nnoremap <space>z :call vimutil#CaptureMessages()<cr>
" explore syntax files for the current filetype
nnoremap <leader>ey :<c-u>call vimutil#ExploreSyntaxFiles()<cr>

" File handling
nnoremap <space>n :e <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>vs :vs <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>sp :sp <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>te :tabedit <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>mv :RenameFile <c-r>=expand("%:p")<cr>
" clone file
nnoremap <leader>ce :saveas <c-r>=expand("%:p")<cr><c-f>F/l
" copy file name to clipboard
nnoremap <leader>cf :let @* = fnameescape(expand("%:t"))<cr>
" copy relative path to clipboard
nnoremap <leader>cp :let @* = fnameescape(expand("%"))<cr>
" copy full path (with ~) to clipboard
nnoremap <leader>cP :let @* = fnameescape(expand("%:~"))<cr>
" copy full path, line and column number
nnoremap <leader>cr :call viewing#CopyCursorReference()<cr>
" go to file path (like vim's gf mapping), but also line and column number
nnoremap <leader>gf :<c-u>call viewing#GoToCursorReference()<cr>
" open file in system view (e.g., pdf, image, csv)
nnoremap <leader>oS :SysOpen<cr>
" open folder of current file in Finder
nnoremap <leader>oF :call fs#OpenFolderInFinder()<cr>

" Search in file
" ---
" search fold markers in buffer (via fzf.vim plugin)
" hack:
"   typing '{' 3 times creates a fold marker in this vimrc.
"   close it with a comment after the mapping.
"   https://stackoverflow.com/a/24717020
nnoremap <space>/f :BLines {{{$<cr>| " }}}
" search in fold
nnoremap <space>/z :call folding#SearchInFold()<cr>
" search in file with Ag
nnoremap <leader>af :SearchInFile<space>
" fzf lines in buffer (via fzf.vim plugin)
nnoremap <space>/b :BLines<cr>
" search operator
nnoremap g/ :set operatorfunc=search#SearchOperator<cr>g@

" Find and Replace / Find and Bulk Change
"
" replace current search term
" (uses abolish.vim so it handles multiple casing)
" See s:SubvertWrap
" :h :Subvert
"
" - replace within file (with confirmation)
nnoremap <leader>rw :%SW/<c-r>=search#SubvertTerm()<cr>/<c-r>=search#SubvertTerm()<cr>/gc<left><left><left>
" - replace within file (no confirmation)
nnoremap <leader>rn :%SW/<c-r>=search#SubvertTerm()<cr>/<c-r>=search#SubvertTerm()<cr>/g<left><left>
vnoremap <leader>rn :SW/<c-r>=search#SubvertTerm()<cr>/<c-r>=search#SubvertTerm()<cr>/g<left><left>
nnoremap <leader>rN :%s/<c-r>=search#Term()<cr>/<c-r>=search#Term()<cr>/g<left><left>
" - replace within line
nnoremap <leader>rl :SW/<c-r>=search#SubvertTerm()<cr>/<c-r>=search#SubvertTerm()<cr>/g<left><left>
" - replace within paragraph
nnoremap <leader>rp :'{,'}SW/<c-r>=search#SubvertTerm()<cr>/<c-r>=search#SubvertTerm()<cr>/g<left><left>
nnoremap <leader>rr :Qargs <Bar> argdo %s/<c-r>=search#Term()<cr>//g <Bar> update<c-f>F/<c-c>
nnoremap <leader>rq :cdo s/<c-r>///g <bar> update<c-f>F/<c-c>
nnoremap <leader>rg :g//exec "normal zR@q"<left>

" Git
nnoremap <space>u :call viewing#ToggleGStatus()<cr>
nnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>go :Git commit<cr>
nnoremap <leader>gh :<c-r>=line('.')<cr>GBrowse<cr>
vnoremap <leader>gh :GBrowse<cr>
" open repo in SourceTree
nnoremap <leader>gs :call fs#OpenInSourceTree()<cr>

" Tags / symbols
nnoremap <space>[ :Tags <c-r><c-w><cr>
nnoremap <space>] :Tags<cr>
nnoremap <space>e :<c-u>call <sid>MaybeSplit() <bar> YcmCompleter GoToDefinition<cr>
nnoremap <leader>ge :call proglang#ListReferences()<cr>
nnoremap <leader>ti :call <sid>ImportSymbol()<cr>
" account for YouCompleteMe getting stuck with Golang
nnoremap <leader>yf :YcmForceCompileAndDiagnostics<cr>
nnoremap <leader>yr :YcmRestartServer<cr>

" Formatting
nnoremap <leader>gp :call proglang#Prettier('')<cr>
vnoremap <leader>gp :<c-u>call proglang#Prettier(visualmode())<cr>
" Format paragraph
nnoremap <space>\ :call editing#FormatParagraph()<cr>

" Count number of matches for current search
nnoremap <leader>co :%s///gn<cr>

" Paste from clipboard in insert and command-line mode
inoremap <c-q> <c-r>*
cnoremap <c-q> <c-r>*

" Insert the current filename with <c-g>f
" (and the built-in <c-r>% is used to insert the current relative path)
inoremap <c-g>f <c-r>=expand('%:t')<cr>
cnoremap <c-g>f <c-r>=expand('%:t')<cr>

" Paste escaped content from clipboard in command-line (search) mode.
" Useful when pasting a path for search.
" Based on search#VisualStar
cnoremap <c-g>e \V<c-r>=substitute(escape(getreg('*'), '/\'), '\n', '\\n', 'g')<cr>

nnoremap <space>r :w<cr>:call RefreshChrome()<cr>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" Go align Elixir paragraph
nmap gae gaipe

" }}}

" Plugin settings ---------------------- {{{

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
let g:ycm_filetype_specific_completion_to_disable = {
\ 'c': 1,
\ 'cpp': 1
\ }
let g:ycm_always_populate_location_list = 1
" disable documentation popup
" (used by Golang)
let g:ycm_auto_hover = ''

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

" }}}
