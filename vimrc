" Plugins ---------------------- {{{
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-sleuth'
Plugin 'vim-airline/vim-airline'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'milkypostman/vim-togglelist'
" Plugin 'Shougo/unite.vim'

Plugin 'jacoborus/tender'

Plugin 'klen/python-mode'

Bundle 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-endwise'
Plugin 'janko-m/vim-test'

Plugin 'dahu/VimRegexTutor'

call vundle#end()
filetype plugin indent on
" }}}

" Settings ---------------------- {{{
syntax on
set background=dark
" colorscheme solarized
colorscheme tender
set number
set relativenumber
set history=1000
set ruler
set showcmd		" display incomplete commands
set incsearch
set backupdir=~/.tmp
set directory=~/.tmp
set hlsearch
set autoindent
set tabstop=4
set shiftwidth=4
set nowrap
set hidden
set laststatus=2 " vim-airline
set t_Co=256
set noeb vb t_vb=
set completeopt=menu
set wildignore+=*.sublime-workspace
set guifont=Menlo\ Regular:h20
set guicursor+=a:blinkon0 " disable cursor blink

" (Hopefully) removes the delay when hitting esc in insert mode
set noesckeys
set ttimeout
set ttimeoutlen=0

" Auto reload file
set autoread
au CursorHold * checktime

:set guitablabel=%t

" }}}

" Auto commands ---------------------- {{{
augroup vimrcEx
    au!

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
" }}}

" Functions ---------------------- {{{
function! NumberToggle()
    if (&relativenumber == 1)
        set norelativenumber
    else
        set relativenumber
    endif
endfunc

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
autocmd BufWritePre * :call TrimWhitespace()

function! OpenCakePHPTest()
    let s:current_file_path = expand("%")
    let s:path_regex = 'app\/plugins\/\(.*\)\/tests\/cases\/\(.*\)'
    let s:match = matchlist(s:current_file_path, s:path_regex)
    if s:match == []
        echom "Not a test file: " . s:current_file_path
        return 1
    endif
    let s:cake_plugin = s:match[1]
    let s:test_case = s:match[2]
    let s:url = "http://wizehive.dev/test.php?case=" . s:test_case . "&plugin=" . s:cake_plugin
    silent exec "!open '" . s:url . "'"
    redraw!
    return 0
endfunction

"}}}

" Mappings ---------------------- {{{
nnoremap <leader>ev :e $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

nnoremap <leader>c "*Y
xnoremap <leader>c "*y
nnoremap <leader>v "*p
nnoremap <leader>V o<esc>"*p
xnoremap <leader>v "*p

nnoremap <leader>w <c-w>w
nnoremap <leader>x :bd<cr>

" :noh (experimenting with <esc> so <c-l> is free to be used with <c-h>)
" nnoremap <silent> <c-l> <c-l>:noh<cr>
nnoremap <silent> <esc> <c-l>:noh<cr>

nnoremap <leader>l :call NumberToggle()<cr>

" File handling
nnoremap <leader>n :e <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>d :e <C-R>=expand("%:h"). "/" <CR><CR>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h') . '/' : '%%'

" Searching
nnoremap <space>a :Ack ""<left>
map <leader>fw :execute "grep " . expand("<cword>") . " **" <Bar> cw<CR>
nnoremap <leader>fr :Qargs <Bar> argdo %s/<C-R><C-W>//gc <Bar> update<C-F>F/<C-C>
nnoremap <Space><Space> :'{,'}s/\<<C-r>=expand('<cword>')<CR>\>/
" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN
nnoremap cg* g*Ncgn
nnoremap cg# g#NcgN

nnoremap <space>f *N

nnoremap <leader>fr ggdG"*P=G

" Save (needs .bashrc: stty -ixon -ixoff)
nnoremap <C-s> <esc>:w<CR>
inoremap <C-s> <esc>:w<CR>

" note: probably could experiment with H and L too
" buffer navigation
nnoremap <C-k> :bnext<cr>
nnoremap <C-j> :bprev<cr>
nnoremap <leader>, :tabm -1<cr>
nnoremap <leader>. :tabm +1<cr>
inoremap <C-k> <esc>:bnext<cr>
inoremap <C-j> <esc>:bprev<cr>

" window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Emacs-like beginning and end of line.
imap <c-e> <c-o>$
imap <c-a> <c-o>^

nnoremap <leader>r :!ruby %<cr>
nnoremap <silent> <leader>T :w<cr>:TestFile --color<cr>
nnoremap <silent> <leader>t :w<cr>:TestLast<cr>
nnoremap <leader>md :!~/programming/wizehive-dev/maya/maya-runner.py sublime-deploy %<CR>

nnoremap <leader>ct :call OpenCakePHPTest()<cr>

nnoremap <silent> <leader>q :call ToggleQuickfixList()<CR>

" this is causing delay when exiting insert mode...
"if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
"	inoremap <silent> <C-[>OA <up>
"	inoremap <silent> <C-[>OB <down>
"	inoremap <silent> <C-[>OC <right>
"	inoremap <silent> <C-[>OD <left>
"endif
" }}}

" Plugin settings ---------------------- {{{
"
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  let g:ackprg = 'ag --vimgrep'
endif

let NERDTreeIgnore = ['\.pyc$', '\.py\~$']
let NERDTreeHijackNetrw = 0
let g:netrw_list_hide = '.*\.DS_Store$,.*\.pyc$'

let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_options_colorcolumn = 0
let g:pymode_run = 0

" let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
" let g:ctrlp_custom_ignore = '\v[\/](node_modules|dist|_runner)'
let g:ctrlp_match_window = 'results:25'
let g:ctrlp_max_files = 0
let g:ctrlp_max_depth = 40
let g:ctrlp_working_path_mode = ''
let g:ctrlp_by_filename = 1

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'
"autocmd VimEnter * AirlineToggleWhitespace
let g:airline_theme = 'tender'

let g:toggle_list_no_mappings = 1

" }}}
