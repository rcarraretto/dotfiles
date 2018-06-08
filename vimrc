" Plugins ---------------------- {{{
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=/usr/local/opt/fzf

if $CUSTOM_NETRW
  set rtp+=$HOME/work/netrw
endif

call vundle#begin()

Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-scriptease'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-dispatch'

Plugin 'wincent/terminus'

Plugin 'mileszs/ack.vim'
Plugin 'junegunn/fzf.vim'

Plugin 'SirVer/ultisnips'

Plugin 'Valloric/YouCompleteMe'
Plugin 'jiangmiao/auto-pairs'
Plugin 'vim-scripts/ReplaceWithRegister'
Plugin 'junegunn/vim-easy-align'
Plugin 'AndrewRadev/splitjoin.vim'

Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-indent'

Plugin 'chriskempson/base16-vim'

Plugin 'janko-m/vim-test'
Plugin 'klen/python-mode'
Plugin 'elixir-lang/vim-elixir'
Plugin 'mustache/vim-mustache-handlebars'

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
        \   execute "normal! g`\"" |
        \ endif
augroup END

if $CUSTOM_NETRW
  augroup CancelNetrw
    autocmd VimEnter * silent! autocmd! FileExplorer
  augroup END
endif

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
  autocmd filetype matlab setlocal commentstring=%\ %s
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

augroup NetrwMapping
  autocmd!
  " note:
  " 'echom' might not work within this function
  " https://vi.stackexchange.com/a/8380
  autocmd filetype netrw call s:NetrwMappings()
augroup END

augroup SetFiletype
  autocmd!
  autocmd BufNewFile,BufRead .luacheckrc set filetype=lua
augroup END

" }}}

" Functions ---------------------- {{{

function! s:NetrwMappings()
  " store original netrw mappings
  if !exists('s:mapping_netrw_cr')
    let s:mapping_netrw_cr = maparg("<cr>", "n")
    let s:mapping_netrw_o = maparg("o", "n")
  endif

  " Cancel netrw default <cr> mapping that will open the file in a new window
  " so <cr> is still : (nnoremap <cr> :)
  let s:mapping_current_cr = maparg("<cr>", "n", 0, 1)
  if !empty(s:mapping_current_cr) && s:mapping_current_cr['buffer']
    nunmap <buffer> <cr>
  endif

  " map 'o' to what <cr> is in netrw (open file in a new window)
  execute "nnoremap <buffer> <silent> o " . s:mapping_netrw_cr

  " map 'x' to what 'o' is in netrw (open file in a horizontal split)
  execute "nnoremap <buffer> <silent> x " . s:mapping_netrw_o
endfunction

function! NumberToggle()
  if (&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
  set number
endfunction

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
endfunction

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

" Adapted from:
" https://github.com/vim-scripts/BufOnly.vim
function! s:BufOnly()
  let buf_nr = bufnr('%')
  let last_buf_nr = bufnr('$')

  let delete_count = 0
  let n = 1
  while n <= last_buf_nr
    if n != buf_nr && buflisted(n)
      if getbufvar(n, '&modified')
        echohl ErrorMsg
        echomsg 'No write since last change for buffer'
              \ n '(add ! to override)'
        echohl None
      else
        silent execute 'bdel ' . n
        if !buflisted(n)
          let delete_count = delete_count + 1
        endif
      endif
    endif
    let n = n + 1
  endwhile

  if delete_count == 1
    echomsg delete_count "buffer deleted"
  elseif delete_count > 1
    echomsg delete_count "buffers deleted"
  endif
endfunction

command! BufOnly :call s:BufOnly()

" Adapted from:
" https://github.com/vim-scripts/Rename
function! s:RenameFile(name)
  let l:oldfile = expand('%:p')

  if bufexists(fnamemodify(a:name, ':p'))
    echohl ErrorMsg
    echomsg 'A buffer with that name already exists.'
    echohl None
    return
  endif

  let v:errmsg = ''
  silent! execute 'saveas ' . a:name

  if v:errmsg !~# '^$\|^E329'
    echoerr v:errmsg
    return
  endif

  if expand('%:p') ==# l:oldfile || !filewritable(expand('%:p'))
    echohl ErrorMsg
    echomsg 'Rename failed for some reason.'
    echohl None
    return
  endif

  let l:lastbufnr = bufnr('$')

  if fnamemodify(bufname(l:lastbufnr), ':p') ==# l:oldfile
    silent execute l:lastbufnr . 'bwipe!'
  else
    echohl ErrorMsg
    echomsg 'Could not wipe out the old buffer for some reason.'
    echohl None
  endif

  if delete(l:oldfile) != 0
    echohl ErrorMsg
    echomsg 'Could not delete the old file: ' . l:oldfile
    echohl None
  endif
endfunction

command! -nargs=1 -complete=file RenameFile call s:RenameFile(<q-args>)

function! ViewFile(path)
  if bufnr(a:path) == -1
    execute "tabnew " . a:path
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      execute "tabnew " . a:path
    else
      call win_gotoid(wins[0])
    endif
  endif
endfunction

"}}}

" Mappings ---------------------- {{{

inoremap jk <esc>

" easier command-line mode
nnoremap <cr> :
xnoremap <cr> :

nnoremap <silent> gh :noh<cr>

" Save (needs .bashrc: stty -ixon -ixoff)
nnoremap <C-l> <esc>:w<CR>
inoremap <C-l> <esc>:w<CR>

" Show output of last command
nnoremap K :!<cr>

" Swap single quote and backtick
nnoremap ' `
vnoremap ' `
onoremap ' `
nnoremap ` '
vnoremap ` '
onoremap ` '

nnoremap <leader><leader> <C-^>

" window navigation
nnoremap <space>k <C-w>k
nnoremap <space>j <C-w>j
nnoremap <space>h <C-w>h
nnoremap <space>l <C-w>l
nnoremap <space>; <C-w>p

" tab navigation
nnoremap <silent> [r :tabprevious<CR>
nnoremap <silent> ]r :tabnext<CR>
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>th :tabm -1<CR>
nnoremap <leader>tl :tabm +1<CR>

nnoremap <space>o :Files<cr>
nnoremap <space>m :History<cr>
nnoremap <silent> <space>i :call ToggleQuickfixList()<CR>
nnoremap <space>q :q<cr>

nnoremap con :call NumberToggle()<cr>
nnoremap [g :colder<cr>
nnoremap ]g :cnewer<cr>

nnoremap <leader>ev :call ViewFile($MYVIMRC)<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>ss :w <bar> :source %<cr>

nnoremap <leader>ess :UltiSnipsEdit<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :call ViewFile("./.todo")<cr>
nnoremap <leader>en :tabedit ~/Dropbox/notes<cr>
nnoremap <leader>et :call ViewFile("~/Dropbox/notes/tmp.txt")<cr>
nnoremap <leader>ei :call ViewFile("~/Dropbox/notes/vim.txt")<cr>

" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN

nnoremap <leader>V o<esc>"*p

" Copy and paste visual
xnoremap <space>c "*y
xnoremap <space>v "*p

" Copy to clipboard 'operator'
nnoremap <space>c "*y
" Replace with clipboard 'operator'
" take advantage of ReplaceWithRegister plugin ('gr' mapping)
nmap <space>v "*gr

" File handling
nnoremap <space>n :e <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>vs :vs <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>sp :sp <C-R>=expand("%:h"). "/" <CR>
nnoremap <leader>dk :e <C-R>=expand('%:h')<cr><cr>
nnoremap <leader>mv :RenameFile <C-R>=expand("%:p")<CR>
nnoremap <leader>cp :let @" = expand("%")<cr>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h') . '/' : '%%'

" Searching
nnoremap <space>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <space>g :<c-u>call <SID>GrepOperator(visualmode())<cr>
nnoremap <space>a :Ack! -Q ''<left>
nnoremap <leader>aa :AckFromSearch<cr>
nnoremap <leader>rw :%s/<C-R>//<C-R>//gc<left><left><left>
nnoremap <leader>rn :%s/<C-R>//<C-R>//g<left><left>
nnoremap <leader>rr :Qargs <Bar> argdo %s/<C-R>///g <Bar> update<C-F>F/<C-C>
nnoremap <leader>rq :cdo s/<C-R>///g <Bar> update<C-F>F/<C-C>
nnoremap <leader>rg :g//exec "normal zR@q"<left>

" Git
nnoremap <space>u :call ToggleGStatus()<CR>
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>go :Gcommit<CR>

" Format paragraph
nnoremap <space>\ gqip

" Count number of matches for current search
nnoremap <leader>co :%s///gn<CR>

nnoremap <leader>rp ggdG"*P=G

nnoremap <silent> <leader>tf :w<cr>:TestFile<cr>
nnoremap <silent> <leader>ts :w<cr>:TestSuite<cr>
nnoremap <silent> <space>t :w<cr>:TestLast<cr>

nnoremap <space>r :w<cr>:call RefreshChrome()<cr>

imap <c-x><c-x> <plug>(fzf-complete-line)

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Go align Elixir paragraph
nmap gae gaipe

nnoremap ]h $]mzzF(B
nnoremap [h [mzzF(B

" Split func args in multiple lines
nnoremap <silent> <leader>gs [(a<cr><esc>])i<cr><esc>[(+:s/, /,\r/g<esc>`.=]):noh<cr>

" move function arg to the right
nnoremap <leader>sl "adt,dwep"ap

" }}}

" Plugin settings ---------------------- {{{
"
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ackprg = 'ag --vimgrep'
  let g:ackhighlight = 1
endif

" Ack.vim
let g:ack_apply_qmappings = 0

" netrw
let g:netrw_list_hide = '.*\.DS_Store$,.*\.pyc$'
let g:netrw_banner = 0
" Tree style listing
let g:netrw_liststyle = 3
" Allow netrw to remove non-empty local directories
let g:netrw_localrmdir = 'rm -r'

" terminus
let g:TerminusCursorShape = 0

" pymode
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
let g:pymode_options_colorcolumn = 0
let g:pymode_run = 0

let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<c-b>"
let g:UltiSnipsJumpBackwardTrigger = "<c-z>"
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
