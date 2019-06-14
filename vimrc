"# vim: set foldmethod=marker:

" Plugins ---------------------- {{{
set nocompatible

set rtp+=/usr/local/opt/fzf
set rtp+=$HOME/work/dotfiles-private/vim
set rtp+=$HOME/work/tsuquyomi

if $CUSTOM_NETRW
  set rtp+=$HOME/work/netrw
endif

call plug#begin('~/.vim/bundle')

Plug 'junegunn/vim-plug'

" >>> Color scheme <<<
Plug 'danielwe/base16-vim', { 'commit': '4533d1ccab2483deabc743e51321d29a259a819e' }

" >>> Search <<<
Plug 'mileszs/ack.vim'
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-sneak'

" >>> Text editing (Part 1) <<<
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'rcarraretto/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'SirVer/ultisnips', { 'commit': '423f264e753cec260b4f14455126e6db7ba429af' }
Plug 'Valloric/YouCompleteMe'
Plug 'AndrewRadev/splitjoin.vim'

" >>> Support <<<
Plug 'tpope/vim-dispatch'
" focus reporting
Plug 'wincent/terminus'
" file system commands
Plug 'tpope/vim-eunuch'
Plug 'janko-m/vim-test'
" git
Plug 'tpope/vim-fugitive', { 'commit': '60eac8c97457af5a96eb06ad4b564e4c813d806e' }
" github
Plug 'tpope/vim-rhubarb'
" debugging vim / vimscript
Plug 'tpope/vim-scriptease', { 'commit': '386f19cd92f7b30cd830784ae22ebbe7033564aa' }

" >>> Text editing (Part 2) <<<
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'beloglazov/vim-textobj-quotes'
Plug 'Julian/vim-textobj-variable-segment'
" indentation
Plug 'tpope/vim-sleuth'
" change word casing, case-aware substitute
Plug 'tpope/vim-abolish'
" readline style for command line mode and insert mode
Plug 'tpope/vim-rsi'
Plug 'junegunn/vim-easy-align'

" >>> Language specific <<<
Plug 'klen/python-mode'
Plug 'elixir-lang/vim-elixir'
Plug 'mustache/vim-mustache-handlebars'
Plug 'leafgarland/typescript-vim'
" Plug 'Quramy/tsuquyomi'
Plug 'jparise/vim-graphql'
Plug 'ianks/vim-tsx'
Plug 'udalov/kotlin-vim'
" View colored output of shell commands
Plug 'chrisbra/Colorizer'

call plug#end()
" }}}

" Settings ---------------------- {{{
let base16colorspace=256  " Access colors present in 256 colorspace"
set background=dark
try
  colorscheme base16-default-dark
catch /^Vim\%((\a\+)\)\=:E185/
endtry

set number
set relativenumber
set history=1000
set ruler
set showcmd		" display incomplete commands
set incsearch
set backupdir=~/.tmp-vim
set directory=~/.tmp-vim
set hlsearch
set smartcase
set ignorecase
set autoindent
set nowrap

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

set shortmess+=A " no warning for existing swap file

set statusline=%f\  " filename
set statusline+=%m  " modified flag
set statusline+=%r  " read only flag
set statusline+=%=  " left/right separator
set statusline+=%1.4l/%1.4L\  " line number / number of lines
set statusline+=\ \|\  " separator
set statusline+=col\ %-3.3v  " column number
set statusline+=\  " separator

function! Qftitle()
  return getqflist({'title': 1}).title
endfunction

function! s:SetStatusline(...)
  if index(['diff', 'undotree'], &filetype) >= 0
    return
  endif
  let isLeaving = get(a:, 1, 0)
  let showFlags = index(['qf', 'help'], &filetype) == -1
  setlocal statusline=%f\  " filename
  if showFlags
    setlocal statusline+=%m  " modified flag
    setlocal statusline+=%r  " read only flag
  endif
  if &ft == 'qf'
    setlocal statusline+=%{Qftitle()}
  endif
  setlocal statusline+=%=  " left/right separator
  if isLeaving
    if &ft == 'qf'
      setlocal statusline+=%1.4l/%1.4L\  " line number / number of lines
      setlocal statusline+=\ \|\  " separator
    endif
    setlocal statusline+=win\ %{tabpagewinnr(tabpagenr())} " window number
    setlocal statusline+=\ \ \  " separator
  else
    setlocal statusline+=%1.4l/%1.4L\  " line number / number of lines
    setlocal statusline+=\ \|\  " separator
    setlocal statusline+=col\ %-3.3v  " column number
    setlocal statusline+=\  " separator
  endif
endfunction

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

" Change error style.
" :h attr-list
" e.g., error gutter
highlight Error ctermfg=red ctermbg=00 cterm=reverse
" e.g., error in some vim setting
highlight vimError ctermfg=red ctermbg=NONE cterm=underline
" e.g., typescript syntax error
highlight SpellBad ctermfg=NONE ctermbg=NONE cterm=underline

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

augroup FTOptions
  autocmd!
  autocmd FileType vim setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal textwidth=0
  autocmd FileType sh setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType javascript setlocal foldmethod=indent | setlocal foldlevel=1 | setlocal formatoptions-=cro
  autocmd FileType typescript setlocal foldmethod=indent | setlocal foldlevel=1
  autocmd FileType json setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType lua setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType ruby setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType c setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType cpp setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType php setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal foldmethod=indent | setlocal foldlevel=1
  autocmd FileType graphql setlocal shiftwidth=4 | setlocal tabstop=4 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType crontab setlocal backupcopy=yes
  autocmd FileType haskell setlocal expandtab
  autocmd FileType matlab setlocal commentstring=%\ %s
  autocmd FileType netrw call s:NetrwMappings()
  " when calling setqflist(), the status line is reset
  autocmd FileType qf call s:SetStatusline()
augroup END

augroup SetFiletype
  autocmd!
  autocmd BufNewFile,BufRead .luacheckrc set filetype=lua
  autocmd BufNewFile,BufRead .ignore set filetype=conf
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
  autocmd BufEnter,FocusGained,VimEnter,WinEnter * call s:OnWinEnter()
  autocmd FocusLost,WinLeave * call s:OnWinLeave()
augroup END

augroup TrimWhitespace
  autocmd!
  autocmd BufWritePre * :call s:TrimWhitespace()
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

augroup RevertPluginSideEffects
  autocmd!
  " unmap what rsi.vim did
  autocmd VimEnter * cunmap <c-f>
augroup END

augroup AutoSaveFolds
  " Whitelist of filetypes that will have folding saved/restored.
  "
  " Using a whitelist because there will be exceptions like
  " quickfix, netrw and help buffers. And also special buffers
  " used by plugins like plug, fzf, fugitive, etc.
  let s:ft_save_fold = ['typescript']
  autocmd!
  " Mkview
  autocmd BufUnload * if index(s:ft_save_fold, &ft) >= 0 | mkview | endif
  " Loadview
  "
  " hack 1: Not using BufWinEnter here because it seems that it doesn't work
  " for the following case:
  " - use Dispatch.vim to call an external tool to change the code (e.g. prettier)
  " - then the buffer will be refreshed by vim
  "   (because of :checktime and &autoread set by terminus plugin)
  " - then it seems like none of the events are being triggered,
  "     BufWinEnter or BufRead or ShellCmdPost or FileChangedShellPost
  "
  " hack 2: after loading view, it seems that the cursor bugs, when going up and down.
  " Going right and left after loadview seems to fix it.
  "
  autocmd FileType typescript silent! loadview | call feedkeys("\<right>\<left>")
augroup END

augroup TmuxGitStatus
  " Refresh tmux status bar, since it shows git branch information.
  " Each buffers has its own current working directory.
  autocmd!
  autocmd BufEnter,DirChanged * silent call system('tmux refresh-client -S')
augroup END

augroup DisableE211
  " Vim sends a warning when a file was initially opened, but then deleted outside of vim.
  "
  " This happpens to me every once in a while
  " when switching git branches while having many buffers open.
  "
  " I find this a bit disrupting when I'm moving back and forth from vim
  " and I have to see this warning every time I come back to it.
  " At the end, I'm forced to break my flow and close the buffers.
  "
  " So just do a hack to disable this behavior.
  " https://stackoverflow.com/a/52781365/2277505
  autocmd!
  autocmd FileChangedShell * call s:FileChangedShell(expand("<afile>:p"))
augroup END

function! s:SneakColor()
  " ctermbg=magenta, ctermbg=16, ctermbg=17 look good
  hi Sneak ctermfg=00 ctermbg=17
endfunction
augroup Sneak
  autocmd!
  autocmd! ColorScheme * call s:SneakColor()
augroup END
call s:SneakColor()

augroup KarabinerEOL
  autocmd!
  " Apparently Karabiner likes to save this file without an EOL
  autocmd BufRead ~/.config/karabiner/karabiner.json setlocal nofixendofline
  autocmd BufRead ~/work/dotfiles/karabiner/*/karabiner.json setlocal nofixendofline
augroup END

" }}}

" Functions ---------------------- {{{

function! s:NetrwMappings()
  " note:
  " 'echom' might not work within this function
  " https://vi.stackexchange.com/a/8380

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

function! s:ToggleRelativeNumber()
  if &relativenumber == 1
    set norelativenumber
  else
    set relativenumber
  endif
  set number
endfunction

function! s:ShouldColorColumn()
  return index(['qf', 'diff', 'undotree'], &filetype) == -1
endfunction

function! s:OnWinEnter()
  call s:SetStatusline()
  if s:ShouldColorColumn()
    let &l:colorcolumn='0'
  endif
endfunction

function! s:OnWinLeave()
  call s:SetStatusline(1)
  if s:ShouldColorColumn()
    let &l:colorcolumn=join(range(1, 255), ',')
  endif
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

function! s:TrimWhitespace()
  let save_cursor = getpos('.')
  %s/\s\+$//e
  call setpos('.', save_cursor)
endfunction

function! RemoveViews()
  let output = system('rm -rf ~/.vim/view/*')
  if v:shell_error
    echom 'RemoveViews: Error: ' . output
  else
    echom 'Views removed'
  endif
endfunction

function! s:ToggleFolding()
  if foldclosed(line('.')) == -1
    " Fold is open.
    " Close one level
    try
      normal! za
    catch /E490/
      echo 'Fold not found'
      return
    endtry
    if foldclosed(line('.')) == -1
      " Fold is still open.
      " This seems to happen when the line is the only line
      " with that fold level.
      normal! za
    endif
  else
    " Fold is closed.
    " Open folds recursively
    normal! zA
  endif
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

" Make * and # work on visual mode.
" From https://github.com/nelstrom/vim-visual-star-search
function! s:VisualStar(cmdtype)
  let temp = @s
  normal! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
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

function! s:EditFile(path)
  if bufnr(a:path) == -1
    execute 'tabnew ' . a:path
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      execute 'tabnew ' . a:path
    else
      call win_gotoid(wins[0])
    endif
  endif
endfunction

function! s:EditFileUpwards(filename)
  let path = findfile(a:filename, '.;' . $HOME)
  if len(path) == 0
    echo 'File not found: ' . a:filename
    return
  endif
  call s:EditFile(path)
endfunction

" Adapted from:
" https://vim.fandom.com/wiki/File_no_longer_available_-_mark_buffer_modified
function s:FileChangedShell(name)
  let msg = 'File "'.a:name.'"'
  let v:fcs_choice = ''
  if v:fcs_reason == "deleted"
    " Set the buffer as 'readonly', instead of displaying E211.
    " By doing this, we can prevent the file from being accidentally saved in vim
    " and thus inadvertently put back into the file system.
    call setbufvar(expand(a:name), '&readonly', '1')
    " Set the buffer as 'modified', so if we quit vim,
    " we're aware that changes will be lost, if we don't save it.
    call setbufvar(expand(a:name), '&modified', '1')
  elseif v:fcs_reason == "time"
    let msg .= " timestamp changed"
  elseif v:fcs_reason == "mode"
    let msg .= " permissions changed"
  elseif v:fcs_reason == "changed"
    let msg .= " contents changed"
    let v:fcs_choice = "ask"
  elseif v:fcs_reason == "conflict"
    let msg .= " CONFLICT --"
    let msg .= " is modified, but"
    let msg .= " was changed outside Vim"
    let v:fcs_choice = "ask"
    echohl ErrorMsg
  else  " unknown values (future Vim versions?)
    let msg .= " FileChangedShell reason="
    let msg .= v:fcs_reason
    let v:fcs_choice = "ask"
    echohl ErrorMsg
  endif
  redraw!
  echomsg msg
  echohl None
endfunction

function! s:SysOpen(filename)
  let ext = fnamemodify(a:filename, ':e')
  if index(['sh'], ext) != -1
    echo 'SysOpen: unsupported extension: ' . ext
    return
  endif
  let output = system('open ' . a:filename)
  if v:shell_error
    echo 'Error: ' . substitute(output, '\n', ' ', 'g')
    return
  endif
endfunction
command! -nargs=1 -complete=file SysOpen call s:SysOpen(<q-args>)

function! FormatJson()
  if &ft !=# 'json'
    echo 'Not a json file'
    return
  endif
  :%!python -m json.tool
endfunction

function! s:HighestWinnr()
  let wins = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == tabpagenr()')
  return wins[-1]['winnr']
endfunction

function! s:CycleWinLeft()
  if winnr() == 1
    execute s:HighestWinnr() . "wincmd w"
  else
    let prev_winnr = winnr()
    execute "normal! \<c-w>h"
    if winnr() == prev_winnr
      execute "normal! \<c-w>w"
    endif
  endif
endfunction

function! s:CycleWinRight()
  if winnr() == s:HighestWinnr()
    1 wincmd w
  else
    let prev_winnr = winnr()
    execute "normal! \<c-w>l"
    if winnr() == prev_winnr
      execute "normal! \<c-w>W"
    endif
  endif
endfunction

function! GetSubstituteTerm()
  " Remove the word boundary atoms
  " that will be present when searching with * and #.
  if match(@/, '\<\(.*\)\>')
    let str = matchstr(@/, '\<\(.*\)\>')
  else
    let str = @/
  endif
  " Make first char lower case,
  " so that the :Subvert replace is always case-aware.
  return tolower(str[0]) . str[1:]
endfunction

function! GetSubstituteTerm2()
  " Remove the word boundary atoms
  " that will be present when searching with * and #.
  if match(@/, '\<\(.*\)\>')
    return matchstr(@/, '\<\(.*\)\>')
  endif
  return @/
endfunction

" :SW command.
" (Wrapper for :Subvert from abolish.vim)
" :Subvert changes the search register when called directly.
" By using this wrap, this can be avoided.
function! s:SubvertWrap(line1, line2, count, args)
  let save_cursor = getpos('.')
  try
    if a:count == 0
      execute "Subvert" . a:args
    else
      execute a:line1 . "," . a:line2 . "Subvert" . a:args
    endif
  catch
    echohl ErrorMsg
    echo v:errmsg
    echohl NONE
  endtry
  call setpos('.', save_cursor)
  return ""
endfunction
command! -nargs=1 -bar -range=0 SW execute s:SubvertWrap(<line1>, <line2>, <count>, <q-args>)

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

" Easier command-line mode
nnoremap <cr> :
xnoremap <cr> :

" Stop highlighting
nnoremap <silent> gh :noh <bar> call sneak#cancel()<cr>

" Save
nnoremap <c-l> <esc>:w<cr>
inoremap <c-l> <esc>:w<cr>

" Show output of last command
nnoremap K :!<cr>

" Use <tab> to toggle folding.
" On Karabiner Elements, <c-i> will send <f6>
" to avoid collision between <tab> and <c-i>.
"
" Requires macOS keyboard setting:
" 'Use F1, F2, etc. keys as standard function keys'
"
" Taken from https://github.com/wincent/wincent
nnoremap <silent> <tab> :call <sid>ToggleFolding()<cr>
nnoremap <f6> <c-i>

" Swap single quote and backtick
nnoremap ' `
vnoremap ' `
onoremap ' `
nnoremap ` '
vnoremap ` '
onoremap ` '

" Edit the alternate file
nnoremap <leader><leader> <c-^>

" Toggle relative number
nnoremap <silent> con :call <sid>ToggleRelativeNumber()<cr>

" Window navigation
nnoremap <space>j <c-w>j
nnoremap <space>k <c-w>k
nnoremap <silent> <space>h :call <sid>CycleWinLeft()<cr>
nnoremap <silent> <space>l :call <sid>CycleWinRight()<cr>
nnoremap <space>; <c-w>p
nnoremap <space>w <c-w><c-w>
nnoremap <space>q :q<cr>

" Quickfix
nnoremap <silent> <space>i :call ToggleQuickfixList()<cr>
nnoremap <silent> <space>. :call ToggleQuickfixList({'split': 'v'})<cr>
nnoremap [g :colder<cr>
nnoremap ]g :cnewer<cr>
nnoremap <leader>da :AbortDispatch<cr>

" Tab navigation
nnoremap <silent> [r :tabprevious<cr>
nnoremap <silent> ]r :tabnext<cr>
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>tc :tabclose<cr>
nnoremap <leader>th :tabm -1<cr>
nnoremap <leader>tl :tabm +1<cr>

" Command-line history
cnoremap <c-p> <up>
cnoremap <c-n> <down>
cnoremap <c-h> <c-p>
cnoremap <c-l> <c-n>

" vimrc, vimscript
nnoremap <leader>ev :call <sid>EditFile($MYVIMRC)<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>ss :w <bar> :source %<cr>

" Quickly edit some files and folders
nnoremap <space>o :Files<cr>
nnoremap <space>m :History<cr>
nnoremap <leader>el :call <sid>EditFile('~/.vim/vimrc.local')<cr>
nnoremap <leader>ess :UltiSnipsEdit<cr>
nnoremap <leader>esp :e ~/work/dotfiles-private/vim/UltiSnips/<c-r>=&filetype<cr>.snippets<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :call <sid>EditFileUpwards(".todo")<cr>
nnoremap <leader>en :tabedit ~/Dropbox/notes<cr>
nnoremap <leader>et :call <sid>EditFile("~/Dropbox/notes/tmp.txt")<cr>
nnoremap <leader>ei :call <sid>EditFile("~/Dropbox/notes/vim.txt")<cr>
nnoremap <leader>em :call <sid>EditFile("~/work/dotfiles-private/README.md")<cr>
nnoremap <leader>eb :call <sid>EditFile("~/.bashrc.local")<cr>
nnoremap <leader>ey1 :execute "edit " . $VIMRUNTIME . "/syntax/" . &syntax . ".vim"<cr>
nnoremap <leader>ey2 :execute "edit ~/.vim/syntax/" . &syntax . ".vim"<cr>
nnoremap <leader>ey3 :execute "edit ~/.vim/after/syntax/" . &syntax . ".vim"<cr>
nnoremap <leader>od :call fzf#run(fzf#wrap({'source': 'ag -g "" --hidden ~/work/dotfiles ~/work/dotfiles-private'}))<cr>
nnoremap <leader>ad :Ack! --hidden -Q '' ~/work/dotfiles/ ~/work/dotfiles-private/<c-f>F'<c-c>
nnoremap <leader>ob :Files ~/.vim/bundle<cr>
nnoremap <leader>oS :call <sid>SysOpen('<c-r>%')<cr>

" Tags
nnoremap <space>[ :Tags <c-r><c-w><cr>
nnoremap <space>] :Tags<cr>
nnoremap <space>e :YcmCompleter GoToDefinition<cr>

" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN

nnoremap <leader>V o<esc>"*p

" Copy and paste visual
xnoremap <space>y "*y
xnoremap <space>p "*p

" Copy to clipboard 'operator'
nnoremap <space>y "*y
" Replace with clipboard 'operator'
" take advantage of ReplaceWithRegister plugin ('gr' mapping)
nmap <space>p "*gr

" Quotes textobj
omap q iq

" File handling
nnoremap <space>n :e <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>vs :vs <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>sp :sp <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>te :tabedit <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>dk :e <c-r>=expand('%:h')<cr><cr>
nnoremap <leader>mv :RenameFile <c-r>=expand("%:p")<cr>
" clone file
nnoremap <leader>ce :saveas <c-r>=expand("%:p")<cr><c-f>F/l
" copy path to clipboard
nnoremap <leader>cp :let @" = expand("%") \| let @* = expand("%")<cr>

" Searching
nnoremap <space>g :set operatorfunc=<sid>GrepOperator<cr>g@
vnoremap <space>g :<c-u>call <sid>GrepOperator(visualmode())<cr>
nnoremap <space>a :Ack! --hidden -Q ''<left>
nnoremap <leader>aa :AckFromSearch<cr>
xnoremap * :<c-u>call <sid>VisualStar('/')<cr>/<c-r>=@/<cr><cr>
xnoremap # :<c-u>call <sid>VisualStar('?')<cr>?<c-r>=@/<cr><cr>

" Find and Replace / Find and Bulk Change
"
" replace current search term
" (uses abolish.vim so it handles multiple casing)
" See s:SubvertWrap
" :h :Subvert
"
" - replace within file (with confirmation)
nnoremap <leader>rw :%SW/<c-r>=GetSubstituteTerm()<cr>/<c-r>=GetSubstituteTerm()<cr>/gc<left><left><left>
" - replace within file (no confirmation)
nnoremap <leader>rn :%SW/<c-r>=GetSubstituteTerm()<cr>/<c-r>=GetSubstituteTerm()<cr>/g<left><left>
vnoremap <leader>rn :SW/<c-r>=GetSubstituteTerm()<cr>/<c-r>=GetSubstituteTerm()<cr>/g<left><left>
nnoremap <leader>rN :%s/<c-r>=GetSubstituteTerm2()<cr>/<c-r>=GetSubstituteTerm2()<cr>/g<left><left>
" - replace within line
nnoremap <leader>rl :SW/<c-r>=GetSubstituteTerm()<cr>/<c-r>=GetSubstituteTerm()<cr>/g<left><left>
" - replace within paragraph
nnoremap <leader>re :'{,'}SW/<c-r>=GetSubstituteTerm()<cr>/<c-r>=GetSubstituteTerm()<cr>/g<left><left>
nnoremap <leader>rr :Qargs <Bar> argdo %s/<c-r>///g <Bar> update<c-f>F/<c-c>
nnoremap <leader>rq :cdo s/<c-r>///g <bar> update<c-f>F/<c-c>
nnoremap <leader>rg :g//exec "normal zR@q"<left>

" Git
nnoremap <space>u :call ToggleGStatus()<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>go :Gcommit<cr>
nnoremap <leader>gh :<c-r>=line('.')<cr>Gbrowse<cr>
vnoremap <leader>gh :Gbrowse<cr>

" Format paragraph
nnoremap <space>\ gqip

" Count number of matches for current search
nnoremap <leader>co :%s///gn<cr>

nnoremap <leader>rf ggdG"*P=G

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

" Move function arg to the right
nnoremap <leader>sl "adt,dwep"ap

" }}}

" Plugin settings ---------------------- {{{

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ackprg = 'ag --vimgrep'
  let g:ackhighlight = 1
endif

" Ack.vim
let g:ack_apply_qmappings = 0

" fzf
" extend actions with mapping to open in system editor
let g:fzf_action = {
\ 'ctrl-t': 'tab split',
\ 'ctrl-x': 'split',
\ 'ctrl-v': 'vsplit',
\ 'ctrl-s': 'SysOpen'
\ }

" Netrw
let g:netrw_list_hide = '.*\.DS_Store$,.*\.pyc$'
let g:netrw_banner = 0
" when previewing files with 'p', split vertically
let g:netrw_preview = 1
" allow netrw to remove non-empty local directories
let g:netrw_localrmdir = 'rm -r'

" Dispatch
let g:dispatch_no_maps = 1
let g:dispatch_tmux_height = 3

" Terminus
let g:TerminusCursorShape = 0

" Pymode
let g:pymode_folding = 0
let g:pymode_options_max_line_length = 119
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

" }}}

" vimrc override ---------------------- {{{

let s:vimrc_local = $HOME . '/.vim/vimrc.local'
if filereadable(s:vimrc_local)
  execute 'source ' . s:vimrc_local
endif

" }}}
