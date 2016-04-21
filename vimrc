set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'

Plugin 'klen/python-mode'
Bundle 'vim-ruby/vim-ruby'

Plugin 'dahu/VimRegexTutor'

call vundle#end()
filetype plugin indent on

syntax on
set background=dark
colorscheme solarized

set relativenumber
set history=1000
set ruler
set showcmd		" display incomplete commands
set incsearch
set autoread
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

" (Hopefully) removes the delay when hitting esc in insert mode
set noesckeys
set ttimeout
set ttimeoutlen=0


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

" Vimscript file settings ---------------------- {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

let NERDTreeIgnore = ['\.pyc$', '\.py\~$']
let NERDTreeHijackNetrw = 0

let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_options_colorcolumn = 0
let g:pymode_run = 0

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
" let g:ctrlp_custom_ignore = '\v[\/](node_modules|dist|_runner)'

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
"autocmd VimEnter * AirlineToggleWhitespace

" this is causing delay when exiting insert mode...
"if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
"	inoremap <silent> <C-[>OA <up>
"	inoremap <silent> <C-[>OB <down>
"	inoremap <silent> <C-[>OC <right>
"	inoremap <silent> <C-[>OD <left>
"endif

function! NumberToggle()
    if (&relativenumber == 1)
        set number
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

map <F4> :execute "vimgrep /" . expand("<cword>") . "/j *" <Bar> cw<CR>
map <F3> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
nnoremap <c-l> <c-l>:noh<cr>
nnoremap <leader>l :call NumberToggle()<cr>
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>md :!~/programming/wizehive-dev/maya/maya-runner.py sublime-deploy %<CR>

" In .bashrc:
" stty -ixon -ixoff
map <C-s> <esc>:w<CR>
imap <C-s> <esc>:w<CR>

" Emacs-like beginning and end of line.
imap <c-e> <c-o>$
imap <c-a> <c-o>^

