" Plugins ---------------------- {{{
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=/usr/local/opt/fzf
call vundle#begin()

Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-scriptease'
Plugin 'tpope/vim-abolish'

Plugin 'wincent/terminus'

Plugin 'mileszs/ack.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'junegunn/fzf.vim'

Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

Plugin 'Valloric/YouCompleteMe'
Plugin 'jiangmiao/auto-pairs'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'junegunn/vim-easy-align'

Plugin 'milkypostman/vim-togglelist'
Plugin 'vim-scripts/BufOnly.vim'
Plugin 'vim-scripts/Rename'

Plugin 'chriskempson/base16-vim'

Plugin 'StanAngeloff/php.vim'
Plugin 'klen/python-mode'
Plugin 'mustache/vim-mustache-handlebars'

Bundle 'vim-ruby/vim-ruby'
Plugin 'elixir-lang/vim-elixir'
Plugin 'janko-m/vim-test'

call vundle#end()
filetype plugin indent on
" }}}

" Settings ---------------------- {{{
syntax on

let base16colorspace=256  " Access colors present in 256 colorspace"
set background=dark
colorscheme base16-default-dark

set number
set relativenumber
set history=1000
set ruler
set showcmd		" display incomplete commands
set incsearch
set backupdir=~/.tmp
set directory=~/.tmp
set hlsearch
set smartcase
set ignorecase
set autoindent
set tabstop=4
set shiftwidth=4
set nowrap
set linebreak
set scrolloff=3
set hidden
set laststatus=2 " always display status line
set t_Co=256
set noeb vb t_vb=
set completeopt=menu
set wildignore+=*.sublime-workspace
set wildmenu
set splitright
set splitbelow
set formatoptions-=cro
set synmaxcol=150
set backspace=indent,eol,start

set shortmess+=A " no warning for existing swap file

" Load aliases for executing shell commands within vim
let $BASH_ENV = "~/.bash_aliases"

" Change for base16-default-dark colorscheme
" colorcolumn + search highlighting doesn't work well
" because base16 Search changes the fgcolor of search
" to be the same as colorcolumn
" making search invisible in colorcolumn
highlight Search ctermbg=none ctermfg=none cterm=underline,bold
" Distinguish Folded bg from CursorLine bg
highlight Folded ctermbg=00

" }}}

" Auto commands ---------------------- {{{
augroup vimrcEx
  autocmd!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END

augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END

augroup filetype_crontab
  autocmd!
  autocmd FileType crontab setlocal backupcopy=yes
augroup END

augroup CursorLine
  autocmd!
  autocmd VimEnter * setlocal cursorline
  autocmd WinEnter * setlocal cursorline
  autocmd BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

augroup ColorColumn
  autocmd!
  autocmd BufEnter,FocusGained,VimEnter,WinEnter * if ShouldColorColumn() | let &l:colorcolumn='0' | endif
  autocmd FocusLost,WinLeave * if ShouldColorColumn() | let &l:colorcolumn=join(range(1, 255), ',') | endif
augroup END

augroup TrimWhitespace
  autocmd!
  autocmd BufWritePre * :call TrimWhitespace()
augroup END

augroup VimCommentary
  autocmd!
  autocmd FileType matlab setlocal commentstring=%\ %s
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

augroup SetFiletype
  autocmd!
  autocmd BufNewFile,BufRead .luacheckrc set filetype=lua
augroup END

" }}}

" Functions ---------------------- {{{
function! NumberToggle()
  if (&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
  set number
endfunc

function! ShouldColorColumn() abort
  let g:RcColorColumnBlacklist = ['diff', 'undotree', 'nerdtree', 'qf']
  return index(g:RcColorColumnBlacklist, &filetype) == -1
endfunction

command! -nargs=0 -bar Qargs execute 'args ' . QuickfixFilenames()
function! QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction

fun! TrimWhitespace()
  let l:save_cursor = getpos('.')
  %s/\s\+$//e
  call setpos('.', l:save_cursor)
endfun

function! RefreshChrome()
  silent exec "!osascript $HOME/.applescript/refresh-chrome.applescript"
  redraw!
  return 0
endfunction

function! ToggleGStatus()
  if buflisted(bufname('.git/index'))
    bd .git/index
  else
    Gstatus
  endif
endfunction

function! s:ExecuteCleanCommand(command)
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  silent execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" Taken from abolish.vim
function! s:camelcase(word)
  let word = substitute(a:word, '-', '_', 'g')
  if word !~# '_' && word =~# '\l'
    return substitute(word,'^.','\l&','')
  else
    return substitute(word,'\C\(_\)\=\(.\)','\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))','g')
  endif
endfunction

" Taken from abolish.vim
function! s:mixedcase(word)
  return substitute(s:camelcase(a:word),'^.','\u&','')
endfunction

" Taken from abolish.vim
function! s:snakecase(word)
  let word = substitute(a:word,'::','/','g')
  let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
  let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
  let word = substitute(word,'[.-]','_','g')
  let word = tolower(word)
  return word
endfunction

function! GuessClassName()
  return s:mixedcase(expand('%:t:r'))
endfunction

function! s:RenameClass(class_name)
  let s:new_filename = s:snakecase(a:class_name)
  let s:new_path = expand('%:h') . '/' . s:new_filename . '.' . expand('%:e')
  silent execute 'Rename ' . s:new_path
  let s:change_class_name = "normal! ?\\<class\\>\<cr>wcw" . a:class_name
  call s:ExecuteCleanCommand(s:change_class_name)
  write
endfunction

function! s:GrepOperator(type)
  if a:type ==# 'v'
    execute "normal! `<v`>y"
  elseif a:type ==# 'char'
    execute "normal! `[v`]y"
  else
    return
  endif
  silent execute "Ack! -Q --hidden " . shellescape(@@)
endfunction

command! -nargs=1 RenameClass call s:RenameClass(<f-args>)

"}}}

" Mappings ---------------------- {{{
nnoremap ' `
nnoremap ` '
vnoremap ' `
vnoremap ` '
onoremap ' `
onoremap ` '

" Show output of last command
nnoremap K :!<cr>

" easier command-line mode
nnoremap <cr> :
nnoremap <space>; :

nnoremap <leader>ev :e $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>ss :w <bar> :source %<cr>

nnoremap <leader>ess :UltiSnipsEdit<cr>
nnoremap <leader>es1 :e ~/.vim/bundle/vim-snippets/UltiSnips<cr>
nnoremap <leader>es2 :e ~/.vim/bundle/vim-snippets/snippets<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :tabedit ./.todo<cr>
nnoremap <leader>en :tabedit ~/Dropbox/notes<cr>
nnoremap <leader>et :tabedit ~/Dropbox/notes/tmp.txt<cr>

nnoremap <space>b :CtrlPBuffer<cr>
nnoremap <space>m :CtrlPMRUFiles<cr>
nnoremap <leader><leader> <C-^>

nnoremap <leader>vv "*p
nnoremap <leader>V o<esc>"*p

" Copy and paste visual
xnoremap <space>c "*y
xnoremap <space>v "*p

" Copy to clipboard 'operator'
nnoremap <space>c "*y
" Replace with clipboard 'operator'
" take advantage of ReplaceWithRegister plugin ('gr' mapping)
nmap <space>v "*gr

nnoremap <leader>79 :wqa<cr>

nnoremap <space>q :q<cr>

nnoremap <silent> [r :tabprevious<CR>
nnoremap <silent> ]r :tabnext<CR>
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>th :tabm -1<CR>
nnoremap <leader>tl :tabm +1<CR>

nnoremap <space>u :call ToggleGStatus()<CR>
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>go :Gcommit<CR>

nnoremap ]h $]mzzF(B
nnoremap [h [mzzF(B

nnoremap <silent> gh :noh<cr>
inoremap jk <esc>

" File handling
nnoremap <space>n :e <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>vs :vs <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>sp :sp <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>dl :e <C-R>=expand("%:h"). "/" <CR><CR>
nnoremap <leader>dk :e <C-R>=expand('%:h')<cr><cr>
nnoremap <leader>mv :Rename <C-R>=expand("%:p")<CR>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h') . '/' : '%%'

" Searching
nnoremap <space>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <space>g :<c-u>call <SID>GrepOperator(visualmode())<cr>
nnoremap <space>a :Ack! -Q ''<left>
nnoremap <leader>ft :Ack! '<C-R>=expand("<cword>")<cr>'<left>
nnoremap <leader>fw :execute "Ack " . expand("<cword>") . " **" <Bar> cw<CR>
nnoremap <leader>f$ /\v\$[A-Za-z_]*<cr>
nnoremap <leader>fv /\v\$<C-R><C-W>\ze[ [-]?<cr>N
nnoremap <leader>rw :%s/<C-R>//<C-R>//gc<left><left><left>
nnoremap <leader>rn :%s/<C-R>//<C-R>//g<left><left>
nnoremap <leader>rr :Qargs <Bar> argdo %s/<C-R>///g <Bar> update<C-F>F/<C-C>
nnoremap <leader>rq :cdo s/<C-R>///g <Bar> update<C-F>F/<C-C>
nnoremap <leader>rg :g//exec "normal zR@q"<left>

nnoremap <space>o :Files<cr>

" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN
nnoremap cg* g*Ncgn
nnoremap cg# g#NcgN

" Count number of matches for current search
nnoremap <leader>co :%s///gn<CR>

nnoremap <space>f *N

nnoremap <leader>rp ggdG"*P=G
nnoremap <leader>cc :RenameClass <C-R>=GuessClassName()<cr>

" Split
nnoremap <silent> gS [(a<cr><esc>])i<cr><esc>[(+:s/, /,\r/g<esc>`.=]):noh<cr>

" Format paragraph
nnoremap <space>\ gqip

" move function arg to the right
nnoremap <leader>sl "adt,dwep"ap

" $hash['key'] => $key
nmap <leader>k4 Bldt[ds]ds'
" $hash['key'] => A::value($hash, 'key')
nmap <leader>kav F$f[ds]i, jkF$ys2f')iA::valuejkf)
" $key => $['key']
nmap <leader>4k ysiw]ysi]'hi
" $obj->method() => $obj['method']
nmap <leader>mk F-df>yst(`ysa']f(2x2F'w
" $obj->getSomething() => $obj['something']
nmap <leader>kgk F-df>yst(`ysa']f(2x2F'w3x~

" Save (needs .bashrc: stty -ixon -ixoff)
" nnoremap <C-s> <esc>:w<CR>
" inoremap <C-s> <esc>:w<CR>
nnoremap <C-l> <esc>:w<CR>
inoremap <C-l> <esc>:w<CR>

" window navigation
nnoremap <space>k <C-w>k
nnoremap <space>j <C-w>j
nnoremap <space>h <C-w>h
nnoremap <space>l <C-w>l

nnoremap <silent> <leader>tf :w<cr>:TestFile<cr>
nnoremap <silent> <leader>ts :w<cr>:TestSuite<cr>
nnoremap <silent> <space>t :w<cr>:TestLast<cr>

nnoremap <space>r :w<cr>:call RefreshChrome()<cr>

nnoremap con :call NumberToggle()<cr>
nnoremap <silent> <space>i :call ToggleQuickfixList()<CR>

" add method
nmap <leader>am ]mOf<tab>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Go align Elixir paragraph
nmap gae gaipe

" }}}

" Plugin settings ---------------------- {{{
"
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ackprg = 'ag --vimgrep'
  let g:ackhighlight = 1
  " Use ag in CtrlP for listing files
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
  let g:ctrlp_use_caching = 1
endif

" ctrlp
let g:ctrlp_working_path_mode = ''
let g:ctrlp_map = '<space>p'
let g:ctrlp_switch_buffer = 0

" netrw
let g:netrw_list_hide = '.*\.DS_Store$,.*\.pyc$'
" Allow netrw to remove non-empty local directories
let g:netrw_localrmdir='rm -r'

" terminus
let g:TerminusCursorShape = 0

" pymode
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_options_colorcolumn = 0
let g:pymode_run = 0

" Toggle Quickfix List
let g:toggle_list_no_mappings = 1

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsSnippetsDir = "~/.vim/UltiSnips"

let g:ycm_key_list_select_completion = ['<Enter>']
let g:ycm_filetype_specific_completion_to_disable = {
\ 'c': 1,
\ 'cpp': 1
\ }

" e: elixir
let g:easy_align_delimiters = {
\ 'e': { 'pattern': '->\|do:' }
\ }

" }}}

" vimrc override ---------------------- {{{

let s:vimrc_local = $HOME . '/.vim/vimrc.local'
if filereadable(s:vimrc_local)
  execute 'source ' . s:vimrc_local
endif

" }}}
