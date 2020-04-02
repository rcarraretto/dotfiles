"# vim: set foldmethod=marker:

" Plugins ---------------------- {{{
set rtp+=/usr/local/opt/fzf
set rtp+=$HOME/work/dotfiles-private/vim

if $USE_NETRW
  set rtp+=$HOME/work/netrw
endif

call plug#begin('~/.vim/bundle')

Plug 'junegunn/vim-plug'

" >>> Color scheme <<<
Plug 'danielwe/base16-vim', { 'commit': '4533d1ccab2483deabc743e51321d29a259a819e' }

" >>> Search <<<
Plug 'mileszs/ack.vim'
Plug 'junegunn/fzf.vim'

" >>> Text editing (Part 1) <<<
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'rcarraretto/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'SirVer/ultisnips', { 'commit': '423f264e753cec260b4f14455126e6db7ba429af' }
Plug 'Valloric/YouCompleteMe', { 'commit': 'a60a394dbee587b6f2dea8416e7bdeb996324f6c' }
Plug 'AndrewRadev/splitjoin.vim'

" >>> Support <<<
Plug 'tpope/vim-dispatch'
" focus reporting
Plug 'wincent/terminus'
" file system commands
Plug 'tpope/vim-eunuch'
Plug 'janko-m/vim-test'
" git
Plug 'tpope/vim-fugitive', { 'commit': 'c452181975761f8b055b88eb1c98f736323510fd' }
" github
Plug 'tpope/vim-rhubarb'
Plug 'cohama/agit.vim'
" debugging vim / vimscript
Plug 'tpope/vim-scriptease', { 'commit': '386f19cd92f7b30cd830784ae22ebbe7033564aa' }
" directory viewer (replaces netrw)
if !$USE_NETRW
  Plug 'justinmk/vim-dirvish'
endif

" >>> Text editing (Part 2) <<<
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'beloglazov/vim-textobj-quotes'
" text obj: e.g. seg_seg_seg, SegSegSeg
Plug 'Julian/vim-textobj-variable-segment'
" text obj: function arguments
Plug 'vim-scripts/argtextobj.vim'
" indentation
Plug 'tpope/vim-sleuth'
" change word casing, case-aware substitute
Plug 'tpope/vim-abolish'
" readline style for command line mode and insert mode
Plug 'tpope/vim-rsi'
Plug 'junegunn/vim-easy-align'

" >>> Language specific <<<
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'elixir-lang/vim-elixir'
Plug 'mustache/vim-mustache-handlebars'
Plug 'leafgarland/typescript-vim', { 'commit': '09cf6a6ecdef11cd32d38213093cfe86660255aa' }
Plug 'Quramy/tsuquyomi', { 'commit': '785af7476e0db2522372ef585c86947fc5625c81' }
Plug 'jparise/vim-graphql'
Plug 'peitalin/vim-jsx-typescript'
Plug 'vim-scripts/applescript.vim'
Plug 'udalov/kotlin-vim'
" PowerShell
Plug 'PProvost/vim-ps1'

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

function! Qftitle()
  return getqflist({'title': 1}).title
endfunction

function! s:SetStatuslineSeparator() abort
  setlocal statusline+=\ \|\ " separator
endfunction

function! s:SetStatuslineLineNums()
  let length = len(string(line('$')))
  if length < 4
    let length = 4
  endif
  let line_min_max = length . "." . length
  " line number / number of lines
  " e.g. %4.4l/%-4.4L
  execute "setlocal statusline+=%" . line_min_max . "l/%-" . line_min_max . "L"
  setlocal statusline+=\  " separator
endfunction

function! GetCwdContext() abort
  " show last path component of cwd
  return '[' . fnamemodify(getcwd(), ':t') . '] '
endfunction

function! GetIndentationInfo() abort
  if &list == 0
    return ''
  endif
  let type = &expandtab ? '<space>' : '<tab>'
  if &softtabstop == 0
    if &tabstop == &shiftwidth
      let length = &tabstop
    else
      let length = 'ts: ' . &tabstop . ' ' . 'sw: ' . &shiftwidth
    endif
  else
    let length = 'ts: ' . &tabstop . ' sts: ' . &softtabstop . ' sw: ' . &shiftwidth
  endif
  return ' | ' . type . ' ' . length
endfunction

function! s:SetStatusline(...)
  if index(['diff', 'undotree'], &filetype) >= 0
    return
  endif
  let isActiveWindow = get(a:, 1, 1)
  let showFlags = index(['qf', 'help', 'rc_git_branches', 'rc_git_log', 'rc_git_diff'], &filetype) == -1
  let showRelativeFilename = index(['qf', 'help'], &filetype) == -1
  setlocal statusline=
  if showRelativeFilename
    if isActiveWindow
      setlocal statusline+=%{GetCwdContext()}
    endif
    " Apparently %f doesn't always show the relative filename
    " https://stackoverflow.com/a/45244610/2277505
    " :h filename-modifiers
    " :~ => Reduce file name to be relative to the home directory
    " :. => Reduce file name to be relative to current directory
    " expand('%:~:.') =>
    " - expands the name of the current file, but prevents the expansion of the tilde (:~)
    " - makes the path relative to the current working directory (:.)
    if isActiveWindow
      " truncate file path when window is active and on a vsplit,
      " as the statusline has several other elements in it.
      if winwidth('.') <= 92
        let max_path_length = ".45"
      elseif winwidth('.') <= 120
        let max_path_length = ".60"
      else
        let max_path_length = ""
      endif
    else
      " when window is inactive, we have less elements in the statusline
      " and therefore it's OK to display the path without truncating it.
      let max_path_length = ""
    endif
    execute "setlocal statusline+=%" . max_path_length . "{expand('%:~:.')}"
    setlocal statusline+=\  " separator
  else
    setlocal statusline+=%f\  " filename
  endif
  if showFlags
    setlocal statusline+=%m  " modified flag
    setlocal statusline+=%r  " read only flag
  endif
  if &ft == 'qf'
    setlocal statusline+=%{Qftitle()}
  endif
  let showSymLink = index(['help', 'fugitive', 'git'], &filetype) == -1
  if showSymLink
    " /path/to/something/ => /path/to/something
    let path = substitute(expand('%'), '\(.*\)/$', '\1', '')
    if path !=# resolve(expand('%'))
      setlocal statusline+=[@]
    endif
  endif
  setlocal statusline+=%=  " left/right separator
  if isActiveWindow && winwidth('.') > 50
    setlocal statusline+=%{GetIndentationInfo()}
    let showFt = index(['qf', ''], &filetype) == -1
    if showFt
      call s:SetStatuslineSeparator()
      setlocal statusline+=%{&ft} " filetype
    endif
    call s:SetStatuslineSeparator()
    call s:SetStatuslineLineNums()  " line number / number of lines
    call s:SetStatuslineSeparator()
    setlocal statusline+=col\ %-3.v " column number
    setlocal statusline+=\  " separator
  elseif !isActiveWindow
    if &ft == 'qf'
      call s:SetStatuslineSeparator()
      call s:SetStatuslineLineNums()  " line number / number of lines
      call s:SetStatuslineSeparator()
    endif
    setlocal statusline+=win\ %{tabpagewinnr(tabpagenr())} " window number
    setlocal statusline+=\ \ \  " separator
  endif
endfunction

" Load aliases for executing shell commands within vim
let $BASH_ENV = "~/.bash_aliases"

" Remove underline from cursor line
" https://stackoverflow.com/a/58181112/2277505
highlight CursorLineNr cterm=bold

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

" color agit diff similar to vim's git diff syntax
" $VIM/vim81/syntax/git.vim
hi def link agitDiffAdd diffAdded
hi def link agitDiffRemove diffRemoved

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

if $USE_NETRW
  augroup CancelNetrw
    autocmd VimEnter * silent! autocmd! FileExplorer
  augroup END
endif

augroup FTOptions
  autocmd!
  autocmd FileType vim setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal textwidth=0 | call s:VimscriptMappings()
  autocmd FileType sh setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType text setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType markdown setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  " my own personal notes format
  autocmd FileType ntx setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=marker | setlocal commentstring=#\ %s
  autocmd FileType javascript setlocal foldmethod=indent | setlocal foldlevel=20 | setlocal formatoptions-=cro
  autocmd FileType typescript,typescript.tsx setlocal foldmethod=indent | setlocal foldlevel=20 | setlocal commentstring=//\ %s
  autocmd FileType json setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType lua setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType ruby setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType c setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType cpp setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType php setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal foldmethod=indent | setlocal foldlevel=1
  autocmd FileType graphql setlocal shiftwidth=4 | setlocal tabstop=4 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType applescript setlocal commentstring=--\ %s
  autocmd FileType crontab setlocal backupcopy=yes
  autocmd FileType haskell setlocal expandtab
  autocmd FileType matlab setlocal commentstring=%\ %s
  autocmd FileType netrw call s:NetrwMappings()
  autocmd FileType dirvish call s:DirvishConfig()
  autocmd FileType agit call s:AgitConfig()
  " when calling setqflist(), the status line is reset
  autocmd FileType qf call s:SetStatusline()
augroup END

augroup SetFiletype
  autocmd!
  autocmd BufNewFile,BufRead .luacheckrc set filetype=lua
  autocmd BufNewFile,BufRead .ignore set filetype=conf
  autocmd BufNewFile,BufRead *.applescript set filetype=applescript
  autocmd BufNewFile,BufRead *.jenkinsfile set filetype=groovy
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

augroup WinConfig
  autocmd!
  autocmd BufEnter,FocusGained,WinEnter * call s:OnWinEnter()
  autocmd FocusLost,WinLeave * call s:OnWinLeave()
augroup END

augroup DisableSyntaxForLargeFiles
  autocmd!
  autocmd BufWinEnter * call s:DisableSyntaxForLargeFiles()
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

augroup VimEnterCustom
  autocmd!
  autocmd VimEnter * call s:VimEnter()
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

" }}}

" Functions ---------------------- {{{

function! s:VimEnter()
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
  nnoremap <buffer> <leader>ss :silent write <bar> :source %<cr>
endfunction

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

function! s:DirvishConfig()
  setlocal nonumber
  setlocal norelativenumber
  call s:DirvishMappings()
endfunction

function! s:DirvishMappings()
  let mapping = maparg("<cr>", "n", 0, 1)
  if empty(mapping) || !mapping['buffer']
    " if there is no nmap <buffer> <cr>,
    " then this function was already executed
    return
  endif
  " keep <cr> as it normally is (nnoremap <cr> :)
  nunmap <buffer> <cr>
  " map 'o' to what <cr> is in dirvish (open file)
  nnoremap <buffer> <silent> o :<c-u>silent call dirvish#open("edit", 0)<cr>
  " map 's' to what 'o' is in dirvish (open file in a horizontal split)
  nnoremap <buffer> <silent> s :<c-u>silent call dirvish#open("split", 1)<cr>
  " rename
  nnoremap <buffer> <silent> R :<c-u>call <sid>DirvishRename()<cr>
  " mkdir
  " - add <nowait> because of 'ds' (Dsurround from surround.vim)
  " - https://vi.stackexchange.com/a/2774
  nnoremap <buffer> <silent> <nowait> d :<c-u>call <sid>DirvishMkdir()<cr>
  " rm
  nnoremap <buffer> <silent> <nowait> D :<c-u>call <sid>DirvishRm()<cr>
  " implode
  nnoremap <buffer> <silent> I :<c-u>call <sid>DirvishImplode()<cr>
  " mv
  nnoremap <buffer> <silent> mv :<c-u>call <sid>DirvishMv()<cr>
endfunction

function! s:DirvishRefresh() abort
  silent edit
  try
    " restore cursor position
    " :h `"
    execute "normal! g`\""
  catch /E19/
    " E19: Mark has invalid line number
    " Line is gone. Ignore it.
    " This happens e.g. when deleting the last file of the list.
  endtry
endfunction

function! s:DirvishRename()
  let path = getline('.')
  let new_path = input('Moving ' . path . ' to: ', path, 'file')
  call rename(path, new_path)
  call s:DirvishRefresh()
endfunction

function! s:DirvishMkdir()
  let dirname = input('Mkdir: ')
  if !len(dirname)
    return
  endif
  let new_path = @% . dirname
  call mkdir(new_path)
  call s:DirvishRefresh()
endfunction

function! s:DirvishRm()
  let path = getline('.')
  echohl Statement
  let ok = input('Remove ' . path . '? ')
  echohl NONE
  " clear input
  normal! :<esc>
  if ok !=# 'y'
    echo 'skipped'
    return
  endif
  if isdirectory(path)
    let output = system('rm -r ' . path)
    if v:shell_error
      echohl Error
      echom 'DirvishRm: Error: ' . output
      echohl NONE
    endif
  elseif filereadable(path)
    call delete(path)
  else
    echohl Error
    echom 'File does not exist'
    echohl NONE
    return
  endif
  call s:DirvishRefresh()
endfunction

" Move contents of folder to parent folder
function s:DirvishImplode()
  let path = getline('.')
  if !isdirectory(path)
    echohl Statement
    echom 'DirvishImplode: not a directory: ' . path
    echohl NONE
    return
  endif
  let dirname = fnamemodify(path[:-2], ':t')
  echohl Statement
  let ok = input("Implode directory '" . dirname . "'? ")
  echohl NONE
  " clear input
  normal! :<esc>
  if ok !=# 'y'
    echo 'skipped'
    return
  endif
  let cmd = 'mv ' . path . '* ' . @% . ' && rmdir ' . path
  let output = system(cmd)
  if v:shell_error
    echohl Error
    echom 'DirvishImplode: Error: ' . output
    echohl NONE
  endif
  call s:DirvishRefresh()
endfunction

function! ArgList()
  let i = 0
  let l = []
  while i < argc()
    call add(l, argv(i))
    let i = i + 1
  endwhile
  return l
endfunction

function! s:DirvishMv()
  let dirpath = getline('.')
  if !isdirectory(dirpath)
    let dirpath = fnamemodify(dirpath, ':h') . '/'
    if !isdirectory(dirpath)
      echohl Statement
      echom 'DirvishMv: target is not a directory: ' . dirpath
      echohl NONE
      return
    endif
  endif
  let cwd = getcwd() . '/'
  let filepaths = filter(ArgList(), 'filereadable(v:val) || (isdirectory(v:val) && v:val != cwd)')
  if len(filepaths) < 1
    echohl Statement
    echom "DirvishMv: no file has been selected (use 'x' to select a file)"
    echohl NONE
    return
  endif
  function! s:shortname(path)
    if isdirectory(a:path)
      return "'" . fnamemodify(a:path[:-2], ':t') . "'"
    endif
    return "'" . fnamemodify(a:path, ':t') . "'"
  endfunction
  let filenames = map(copy(filepaths), 's:shortname(v:val)')
  let dirname = s:shortname(dirpath)
  echohl Statement
  let ok = input("Move " . join(filenames, ', ') . " to directory " . dirname . "? ")
  echohl NONE
  " clear input
  normal! :<esc>
  if ok !=# 'y'
    echo 'skipped'
    return
  endif
  let cmd = 'mv ' . join(filepaths, ' ') . ' ' . dirpath
  let output = system(cmd)
  if v:shell_error
    echohl Error
    echom 'DirvishMv: Error: ' . output
    echohl NONE
  endif
  argdelete *
  execute "Dirvish " . dirpath
endfunction


if !$USE_NETRW
  " Replacement for netrw 'gx',
  " but just for urls
  function! s:OpenUrl()
    let url = expand('<cfile>')
    if url !~ 'http\(s\)\?:\/\/'
      echo 'Not a url: ' . url
      return
    endif
    silent exec "!open '" . shellescape(url, 1) . "'"
    redraw!
  endfunction
  nnoremap gx :call <sid>OpenUrl()<cr>
endif

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

" Executes callback function for all windows.
"
" based on https://vi.stackexchange.com/a/12068
"
function! s:GlobalWinDo(callback) abort
  for t in range(1, tabpagenr('$'))
    for w in range(1, tabpagewinnr(t, '$'))
      call function(a:callback)(t, w)
    endfor
  endfor
endfunction

function! s:ToggleRelativeNumber() abort
  " buffers that don't have 'number' set won't be touched
  " (e.g., dirvish, fugitive, agit)

  function! s:SetNoRelativeNumber(t, w) abort
    if gettabwinvar(a:t, a:w, '&number') == 1
      call settabwinvar(a:t, a:w, '&relativenumber', 0)
    endif
  endfunction

  function! s:SetRelativeNumber(t, w) abort
    if gettabwinvar(a:t, a:w, '&number') == 1
      call settabwinvar(a:t, a:w, '&relativenumber', 1)
    endif
  endfunction

  if &number == 0
    echohl ErrorMsg
    echom "ToggleRelativeNumber: can only be triggered when 'number' is set"
    echohl NONE
    return
  endif

  if &relativenumber
    call s:GlobalWinDo('s:SetNoRelativeNumber')
  else
    call s:GlobalWinDo('s:SetRelativeNumber')
  endif
endfunction

function! s:ToggleListChars()
  if &list
    setlocal nolist
  else
    setlocal list
  endif
endfunction

function! s:ShouldColorColumn()
  return index(['qf', 'diff', 'undotree', 'agit', 'agit_stat', 'agit_diff', 'rc_git_log', 'rc_git_branches', 'rc_git_diff', 'fugitive', 'fugitiveblame'], &filetype) == -1
endfunction

function! s:ShouldCursorLine()
  return index(['agit_diff', 'rc_git_diff'], &filetype) == -1
endfunction

function! s:OnWinEnter()
  if s:ShouldCursorLine()
    setlocal cursorline
  endif
  call s:SetStatusline()
  if s:ShouldColorColumn()
    let &l:colorcolumn='0'
  endif
endfunction

function! s:OnWinLeave()
  setlocal nocursorline
  call s:SetStatusline(0)
  if s:ShouldColorColumn()
    let &l:colorcolumn=join(range(1, 255), ',')
  endif
endfunction

function! s:DisableSyntaxForLargeFiles()
  if index(['help'], &filetype) >= 0
    return
  endif
  if line("$") > 10000
    syntax clear
  endif
endfunction

function! s:QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(values(buffer_numbers))
endfunction
command! -nargs=0 -bar Qargs execute 'args ' . s:QuickfixFilenames()

function! s:TrimWhitespace()
  if &modifiable == 0
    return
  endif
  let save_cursor = getpos('.')
  %s/\s\+$//e
  call setpos('.', save_cursor)
endfunction

function! s:CdToGitRoot(cd_cmd)
  let output = util#GetGitRoot()
  if empty(output)
    echohl ErrorMsg
    echom "CdToGitRoot: couldn't find git root"
    echohl NONE
    return
  endif
  execute a:cd_cmd . ' ' . output
  pwd
endfunction

function! s:OpenInSourceTree()
  let output = util#GetGitRoot()
  if empty(output)
    echohl ErrorMsg
    echom "OpenInSourceTree: couldn't find git root"
    echohl NONE
    return
  endif
  call system('open -a SourceTree ' . output)
endfunction

" Remove views.
" Usually call this because folding is buggy.
function! s:RemoveViews()
  if !util#prompt('Delete all buffers and remove views?')
    return
  endif
  " Delete all buffers first.
  " Else buffers with buggy views will save their buggy info once they unload.
  " (see AutoSaveFolds augroup)
  %bd
  let output = system('rm -rf ~/.vim/view/*')
  if v:shell_error
    echom 'RemoveViews: Error: ' . output
  else
    echom 'Views removed'
  endif
endfunction
command! RemoveViews :call s:RemoveViews()

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
    wincmd T
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
  silent execute "Ag -Q --hidden " . shellescape(@@)
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
    silent execute 'tabnew ' . a:path
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      silent execute 'tabnew ' . a:path
    else
      call win_gotoid(wins[0])
    endif
  endif
endfunction

function! s:EditFileUpwards(filename)
  if filereadable(a:filename)
    " When exploring the root folder with Dirvish and
    " the file is at the root.
    " findfile() does not seem to work with Dirvish in that case.
    call s:EditFile(a:filename)
    return
  endif
  " Search from the directory of the current file upwards, until the home folder
  let path = findfile(a:filename, '.;' . $HOME)
  if !empty(path)
    call s:EditFile(path)
    return
  endif
  " Search from cwd upwards, until the home folder.
  " This might help in case the current file is outside of cwd (e.g. a Dropbox note).
  let path = findfile(a:filename, getcwd() . ';' . $HOME)
  if !empty(path)
    call s:EditFile(path)
    return
  endif
  echo 'File not found: ' . a:filename
endfunction

function! s:EditSketchBuffer(ft)
  if a:ft ==# 'typescript'
    call s:EditFile('~/work/dotfiles-private/src/sketch.ts')
    nnoremap <buffer> <space>t :update <bar> Dispatch! ts-node --project ~/work/dotfiles-private/tsconfig.json % <bar>& tee /var/tmp/test-results.txt /var/tmp/test-console.txt<cr>
  elseif a:ft ==# 'javascript'
    call s:EditFile('~/work/dotfiles-private/src/sketch.js')
    nnoremap <buffer> <space>t :update <bar> Dispatch! node % <bar>& tee /var/tmp/test-results.txt /var/tmp/test-console.txt<cr>
  else
    return util#error_msg(printf('EditSketchBuffer: unsupported filetype: %s', a:ft))
  endif
endfunction
command! -nargs=1 EditSketchBuffer call s:EditSketchBuffer(<q-args>)

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

function! s:ExploreProject(path, opencmd)
  execute a:opencmd a:path . " | lcd " . a:path
  " Somehow the statusline doesn't get properly rendered,
  " when calling this from FzfExploreProject().
  call s:SetStatusline()
endfunction
command! -nargs=1 -complete=file ExploreProject call s:ExploreProject(<q-args>, 'edit')
command! -nargs=1 -complete=file TExploreProject call s:ExploreProject(<q-args>, 'tabedit')
command! -nargs=1 -complete=file VExploreProject call s:ExploreProject(<q-args>, 'vs')
command! -nargs=1 -complete=file HExploreProject call s:ExploreProject(<q-args>, 'sp')

function! s:FzfExploreProject()
  " 1) folders in ~/work and ~/.vim/bundle
  let cmd1 = 'find ~/work ~/.vim/bundle -mindepth 1 -maxdepth 1 -type d'
  " 2) folders in the git root that have a package.json
  "    (to explore backend and frontend node projects that are in the same git repo)
  let cmd2 = 'git rev-parse --show-toplevel 2> /dev/null '
  let cmd2 = cmd2 . '| xargs -I GIT_PATH find GIT_PATH -maxdepth 3 -not -path "*/node_modules/*" -name package.json '
  let cmd2 = cmd2 . '| sed -n "s_/package.json__p"'
  let cmd = cmd2 . '; ' . cmd1 . ';'
  call s:FzfExplorePaths(cmd)
endfunction

function! s:FzfExplorePaths(cmd) abort
  let action = {
        \ '': 'ExploreProject',
        \ 'ctrl-t': 'TExploreProject',
        \ 'ctrl-x': 'HExploreProject',
        \ 'ctrl-v': 'VExploreProject',
        \ }
  call s:FzfWithAction(a:cmd, action)
endfunction

function! s:FzfWithAction(cmd, action) abort
  let opts = {'source': a:cmd, 'down': '~40%' }
  " Put custom actions, instead of using g:fzf_action.
  " This is based on fzf#wrap().
  let opts._action = a:action
  let opts.options = ' --expect='.join(keys(opts._action), ',')
  let CommonSink = s:GetScriptFunc('/usr/local/Cellar/fzf/.*/plugin/fzf.vim', 'common_sink')
  function! opts.sink(lines) abort closure
    " Example of a:lines
    " [] (when ctrl-c was pressed)
    " ['ctrl-t', '~/work/some-project']
    return CommonSink(self._action, a:lines)
  endfunction
  let opts['sink*'] = remove(opts, 'sink')
  call fzf#run(opts)
endfunction

function! s:FzfExploreNodeModules() abort
  if !isdirectory(getcwd() . '/node_modules')
    return util#error_msg('FzfExploreNodeModules: No node modules found in ' . getcwd())
  endif
  let cmd = 'find node_modules -mindepth 1 -maxdepth 1'
  call s:FzfExplorePaths(cmd)
endfunction

function! s:SearchNotes(input) abort
  execute 'Ag --hidden -Q "' . a:input . '" -G "\.txt$" ~/Dropbox/notes/'
endfunction
command! -nargs=* SearchNotes call s:SearchNotes(<q-args>)

function! s:SearchDotfiles(input) abort
  execute 'Ag --hidden -Q "' . a:input . '" ~/work/dotfiles/ ~/work/dotfiles-private/'
endfunction
command! -nargs=* SearchDotfiles :call <sid>SearchDotfiles(<q-args>)

function! s:SearchInGitRoot(input) abort
  let path = util#GetGitRoot()
  if empty(path)
    let path = util#GetGitRoot(getcwd())
  endif
  if empty(path)
    return util#error_msg('SearchInGitRoot: Git root not found')
  endif
  execute 'Ag --hidden -Q "' . a:input . '" ' . path
endfunction
command! -nargs=* SearchInGitRoot :call <sid>SearchInGitRoot(<q-args>)

function! s:SearchInFile(input) abort
  let path = expand('%:p')
  if empty(path)
    echohl ErrorMsg
    echom 'SearchInFile: current buffer has invalid path'
    echohl NONE
    return
  endif
  if isdirectory(path)
    echohl ErrorMsg
    echom 'SearchInFile: current buffer is a directory'
    echohl NONE
    return
  endif
  execute 'Ag -Q "' . a:input . '" ' . path
  cfirst
endfunction
command! -nargs=* SearchInFile :call <sid>SearchInFile(<q-args>)

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

function! s:JsonFormat()
  if &ft !=# 'json'
    echo 'Not a json file'
    return
  endif
  :%!python -m json.tool
endfunction
command! JsonFormat call s:JsonFormat()

function! s:JsonSortKeys() abort
  if &ft !=# 'json'
    return util#error_msg('JsonSortKeys: Not a json file')
  endif
  if !executable('jq')
    return util#error_msg("JsonSortKeys: 'jq' tool is not installed")
  endif
  %!jq -S '.'
endfunction
command! JsonSortKeys call s:JsonSortKeys()

function! s:Prettier() abort
  let parser=''
  if &ft == 'json'
    let parser='json'
  elseif index(['javascript', 'typescript', 'typescript.jsx'], &ft) >= 0
    let parser='babel'
  elseif &ft == 'markdown'
    let parser='markdown'
  endif
  if empty(parser)
    return util#error_msg('Unsupported filetype: ' . &ft)
  endif
  let save_pos = getpos('.')
  execute "%!prettier --config=" . $HOME . "/work/dotfiles-private/.prettierrc --parser=" . parser
  call setpos('.', save_pos)
  silent! write
endfunction
command! Prettier call s:Prettier()

function! s:HighestWinnr()
  let wins = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == tabpagenr()')
  return wins[-1]['winnr']
endfunction

function! s:CycleWinLeft()
  if winnr() == 1
    " This is the first window.
    " Go to the last window.
    " (i.e., cycle instead of moving left)
    "
    " This is a possible layout:
    "  *A* |  B
    " -----------
    "   C  |  D
    "
    " In this case, it moves from A to D.
    execute s:HighestWinnr() . "wincmd w"
  else
    " Move left
    let prev_winnr = winnr()
    execute "normal! \<c-w>h"
    if winnr() == prev_winnr
      " Couldn't move left.
      " This is likely the layout:
      "   A  |  B
      " -----------
      "  *C* |  D
      "
      " In this case, move from C to B.
      execute "normal! \<c-w>w"
    endif
  endif
endfunction

function! s:CycleWinRight()
  if winnr() == s:HighestWinnr()
    " This is the last 'normal' window.
    " Go back to window #1.
    " (i.e., cycle instead of moving right)
    1 wincmd w
  else
    let prev_winnr = winnr()
    " Move right
    execute "normal! \<c-w>l"
    if winnr() == prev_winnr
      " Couldn't move right.
      " This is likely the layout:
      "   A  | *B*
      " -----------
      "   C  |  D
      "
      " In this case, move from B to C.
      execute "normal! \<c-w>W"
    endif
  endif
endfunction

function! GetSubstituteTerm()
  let str = GetSubstituteTerm2()
  " Make first char lower case,
  " so that the :Subvert replace is always case-aware.
  return tolower(str[0]) . str[1:]
endfunction

function! GetSubstituteTerm2()
  " Handle VisualStar.
  "
  " "\Vbatata" => "batata"
  "
  " Note: \V has a special meaning in vim regex,
  " therefore we need to write \\V to match "\V".
  if match(@/, '^\\V\(.*\)') != -1
    return matchlist(@/, '^\\V\(.*\)')[1]
  endif

  " Remove the word boundary atoms
  " that will be present when searching with * and #.
  "
  " "\<batata\>" => "batata"
  "
  " Note: \< and \> have a special meaning in vim regex (word boundary),
  " therefore we need to write \\< and \\> to match "\<" and "\>".
  if match(@/, '^\\<\(.*\)\\>$') != -1
    return matchlist(@/, '^\\<\(.*\)\\>$')[1]
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

function! s:WrapCommand(cmd)
  try
    execute a:cmd
  catch /E363/
    " if the command edits a file (e.g. fzf :Files), the file may be too large.
    " E363 will be displayed along with a trace.
    " Also, the status line will not be rendered properly.
    " Ignore E363 and redraw the status line.
    call s:SetStatusline()
  endtry
endfunction
command! -nargs=1 -complete=command WrapCommand call s:WrapCommand(<q-args>)

" Access script-scope function
" https://stackoverflow.com/a/39216373/2277505
function! s:GetScriptFunc(scriptpath, funcname)
  let scriptnames = split(execute('scriptnames'), "\n")
  let scriptnames_line = matchstr(scriptnames, '.*' . a:scriptpath)
  if empty(scriptnames_line)
    echom "GetScriptFunc: Script not found: " . a:scriptpath
    return
  endif
  let snr = matchlist(scriptnames_line, '^\s*\(\d\+\)')[1]
  if empty(snr)
    echom "GetScriptFunc: Script number not found: " . scriptnames_line
    return
  endif
  let full_funcname = '<SNR>' . snr . '_' . a:funcname
  try
    return function(full_funcname)
  catch /E700/
    echom "GetScriptFunc: Function not found: " . full_funcname
  endtry
endfunction

" Adapt :History from fzf.vim,
" to cope with dirvish.vim
"
" Expected Behavior of --header-lines
" - when editing a file, the current file will be a header
" - else (e.g., quickfix, dirvish), there will be no header
"
" To achieve this, the original implementation sets --header-lines 1,
" when there is a buffer-name.
"
" However, dirvish sets the buffer-name.
" As a consequence, :History gains a header when called from dirvish buffer.
"
function! s:FzfHistory(...)
  " To make this supposedly simpler, we copy the body of the fzf#vim#history.
  " Then we use a hack to access script-scope functions from fzf.vim.
  " 1) Call any function to trigger the sourcing fzf.vim autoload.
  call fzf#vim#_uniq([])
  " 2) Use a hack to get the script-scope functions
  let Fzf = s:GetScriptFunc('autoload/fzf/vim.vim', 'fzf')
  let All_files = s:GetScriptFunc('autoload/fzf/vim.vim', 'all_files')
  if empty(Fzf) || empty(All_files)
    return
  endif
  " 3) Adapt
  " if buffer-name is set and it's not a directory, then put a header
  let header = !empty(expand('%')) && !isdirectory(expand('%'))
  return Fzf('history-files', {
  \ 'source':  All_files(),
  \ 'options': ['-m', '--header-lines', header, '--prompt', 'Hist> ']
  \}, a:000)
endfunction
command! -bang -nargs=* FzfHistory call s:FzfHistory(<bang>0)

function! s:StatelessGrep(prg, format, args) abort
  let prg_back = &l:grepprg
  let format_back = &grepformat
  try
    let &l:grepprg = a:prg
    let &grepformat = a:format
    " Escape special chars because of vim cmdline, to avoid e.g.:
    " E499: Empty file name for '%' or '#', only works with ":p:h"
    let args = escape(a:args, '|#%')
    silent execute 'grep!' args
  finally
    let &l:grepprg = prg_back
    let &grepformat = format_back
  endtry
  " fix screen going blank after :grep
  redraw!
  botright copen
endfunction

function! s:AgVimgrep(format, args) abort
  call s:StatelessGrep('ag --vimgrep', a:format, a:args)
endfunction

function! s:AgSetHighlight(args) abort
  let @/ = matchstr(a:args, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
  call feedkeys(":let &hlsearch=1 \| echo\<cr>", "n")
endfunction

function! s:AgSearchFromSearchReg() abort
  let search = getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search, '\(\\<\|\\>\)', '\\b', 'g')
  return '"' . search . '"'
endfunction

" :Ag command.
" Based on ack.vim (ack#Ack)
function! s:Ag(args) abort
  let format = '%f:%l:%c:%m,%f:%l:%m'
  if empty(a:args)
    return s:AgVimgrep(format, s:AgSearchFromSearchReg())
  endif
  call s:AgVimgrep(format, a:args)
  call s:AgSetHighlight(a:args)
endfunction
" The :Ack command from ack.vim uses -complete=files,
" which causes <q-args> to expand characters like # and % (unless you escape them).
" For this reason, this :Ag command doesn't use file completion.
command! -nargs=* Ag call s:Ag(<q-args>)

function! s:ExploreSyntaxFiles() abort
  let script_paths = s:GetScriptPaths()
  let paths = []
  for script_path in script_paths
    if match(script_path, 'syntax/' . &syntax . '.vim') >= 0
      call add(paths, script_path)
    endif
  endfor
  if empty(paths)
    return util#error_msg('ExploreSyntaxFiles: no syntax files found')
  endif
  let items = map(paths, "{'filename': v:val}")
  call setqflist(items)
  botright copen
  wincmd p
  cfirst
endfunction

" Get full paths from :scriptnames
function! s:GetScriptPaths() abort
   return map(split(execute('scriptnames'), "\n"), 'fnamemodify(substitute(v:val, ''^\s*\d*: '', "", ""), '':p'')')
endfunction

function! s:FormatParagraph() abort
  if getline('.')[0] == '|'
    " table (using easy-align)
    let save_pos = getpos('.')
    normal gaip*|
    call setpos('.', save_pos)
  else
    " paragraph
    normal! gqip
  endif
endfunction

function! s:VSplitRight(path) abort
  " backup
  let prev = &splitright
  " split
  if prev == 0
    set splitright
  endif
  execute "vsplit " . a:path
  " restore
  if prev == 0
    set nosplitright
  endif
endfunction
command! -nargs=? -complete=file VSplitRight :call s:VSplitRight(<q-args>)

function! s:VSplitLeft(path) abort
  " backup
  let prev = &splitright
  " split
  if prev == 1
    set nosplitright
  endif
  execute "vsplit " . a:path
  " restore
  if prev == 1
    set splitright
  endif
endfunction
command! -nargs=? -complete=file VSplitLeft :call s:VSplitLeft(<q-args>)

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
" Toggle showing whitespace
nnoremap <silent> col :call <sid>ToggleListChars()<cr>

" Window navigation
nnoremap <space>j <c-w>j
nnoremap <space>k <c-w>k
nnoremap <silent> <space>h :call <sid>CycleWinLeft()<cr>
nnoremap <silent> <space>l :call <sid>CycleWinRight()<cr>
nnoremap <space>; <c-w>p
nnoremap <space>w <c-w><c-w>
nnoremap <space>q :q<cr>
nnoremap <space>Q :bd!<cr>

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

" Browse files & search
" quickly edit some files and folders
nnoremap <leader>el :call <sid>EditFile('~/.vim/vimrc.local')<cr>
nnoremap <leader>ess :UltiSnipsEdit<cr>
nnoremap <leader>esp :e ~/work/dotfiles-private/vim/UltiSnips/<c-r>=&filetype<cr>.snippets<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :call <sid>EditFileUpwards(".todo")<cr>
nnoremap <leader>en :call fzf#run(fzf#wrap({'source': 'find ~/Dropbox/notes -type f -name "*.txt"'}))<cr>
nnoremap <leader>et :call <sid>EditFile("~/Dropbox/notes/misc.txt")<cr>
nnoremap <leader>ei :call <sid>EditFile("~/Dropbox/notes/dev/dev.txt")<cr>
nnoremap <leader>em :call <sid>EditFile("~/work/dotfiles-private/README.md")<cr>
nnoremap <leader>eb :call <sid>EditFile("~/.bashrc.local")<cr>
nnoremap <leader>ek :call <sid>EditSketchBuffer(&ft)<cr>
nnoremap <leader>ep :call <sid>FzfExploreProject()<cr>
" explore syntax files for the current filetype
nnoremap <leader>ey :call <sid>ExploreSyntaxFiles()<cr>
" browse files
nnoremap <space>o :WrapCommand Files<cr>
" browse files under version control
nnoremap <space>O :GFiles<cr>
" browse history
nnoremap <space>m :WrapCommand FzfHistory<cr>
" browse dotfiles
nnoremap <leader>od :call fzf#run(fzf#wrap({'source': 'ag -g "" --hidden ~/work/dotfiles ~/work/dotfiles-private'}))<cr>
" browse node_modules
nnoremap <leader>eM :call <sid>FzfExploreNodeModules()<cr>
" Ag from search reg
nnoremap <leader>aa :Ag<cr>
" search dotfiles
nnoremap <leader>ad :SearchDotfiles<space>
" search notes
nnoremap <leader>an :SearchNotes<space>
" search in file
nnoremap <leader>af :SearchInFile<space>
" browse source code of vim plugins
nnoremap <leader>ob :Files ~/.vim/bundle<cr>
" browse Downloads, most recent first
nnoremap <leader>ol :call fzf#run(fzf#wrap({'source': 'ls -dt ~/Downloads/*'}))<cr>
" browse commands
" (<c-x> executes the command directly)
nnoremap <space>c :Commands<cr>
" browse command-line history
nnoremap <space>: :History:<cr>
" search in project
nnoremap <space>a :Ag --hidden -Q ''<left>
" search in git root
nnoremap <space>A :SearchInGitRoot<space>
nnoremap <space>g :set operatorfunc=<sid>GrepOperator<cr>g@
vnoremap <space>g :<c-u>call <sid>GrepOperator(visualmode())<cr>
" search in file (from visual mode)
xnoremap * :<c-u>call <sid>VisualStar('/')<cr>/<c-r>=@/<cr><cr>
xnoremap # :<c-u>call <sid>VisualStar('?')<cr>?<c-r>=@/<cr><cr>
" change directory
nnoremap <silent> <leader>cg :call <sid>CdToGitRoot('lcd')<cr>
nnoremap <silent> <leader>tg :call <sid>CdToGitRoot('tcd')<cr>

" Tags
nnoremap <space>[ :Tags <c-r><c-w><cr>
nnoremap <space>] :Tags<cr>
nnoremap <space>e :silent YcmCompleter GoToDefinition<cr>
nnoremap <leader>js :split <bar> silent YcmCompleter GoToDefinition<cr>
nnoremap <leader>jv :vsplit <bar> silent YcmCompleter GoToDefinition<cr>

" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN

nnoremap <leader>V o<esc>"*p

" Copy and paste visual
xnoremap <space>y "*y
xnoremap <space>p "*p

" Quotes textobj
omap q iq

" File handling
nnoremap <space>n :e <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>vs :vs <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>sp :sp <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>te :tabedit <c-r>=expand("%:h"). "/" <cr>
nnoremap <leader>mv :RenameFile <c-r>=expand("%:p")<cr>
" clone file
nnoremap <leader>ce :saveas <c-r>=expand("%:p")<cr><c-f>F/l
" copy relative path to clipboard
nnoremap <leader>cp :let @* = expand("%")<cr>
" copy full path (with ~) to clipboard
nnoremap <leader>cP :let @* = expand("%:~")<cr>
" open file in system view (e.g., pdf, image, csv)
nnoremap <leader>oS :call <sid>SysOpen('<c-r>%')<cr>

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
nnoremap <leader>rp :'{,'}SW/<c-r>=GetSubstituteTerm()<cr>/<c-r>=GetSubstituteTerm()<cr>/g<left><left>
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
nnoremap <leader>gg :Agit<cr>
" open repo in SourceTree
nnoremap <leader>gs :call <sid>OpenInSourceTree()<cr>

" Format paragraph
nnoremap <space>\ :call <sid>FormatParagraph()<cr>

" Count number of matches for current search
nnoremap <leader>co :%s///gn<cr>

" Replace entire content of file with clipboard
nnoremap <leader>rf ggdG"*P=G

" Paste from clipboard in insert and command-line mode
inoremap <c-q> <c-r>*
cnoremap <c-q> <c-r>*

" Insert the current filename with <c-g>f
" (and the built-in <c-r>% is used to insert the current relative path)
inoremap <c-g>f <c-r>=expand('%:t')<cr>
cnoremap <c-g>f <c-r>=expand('%:t')<cr>

" Paste escaped content from clipboard in command-line (search) mode.
" Useful when pasting a path for search.
cnoremap <c-g>e <c-r>=escape(getreg('*'), '/~')<cr>

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
\ '': 'silent edit ',
\ 'ctrl-t': 'silent tab split',
\ 'ctrl-x': 'silent split',
\ 'ctrl-v': 'silent vsplit',
\ 'ctrl-f': 'silent VSplitLeft',
\ 'ctrl-s': 'SysOpen'
\ }

" Netrw
" cancel netrw altogether
if !$USE_NETRW
  let g:loaded_netrwPlugin = 1
endif
let g:netrw_list_hide = '.*\.DS_Store$,.*\.pyc$'
let g:netrw_banner = 0
" when previewing files with 'p', split vertically
let g:netrw_preview = 1

" Dirvish
" sort: folders first
let g:dirvish_mode = ':sort ,^.*[\/],'

" Dispatch
let g:dispatch_no_maps = 1
let g:dispatch_tmux_height = 3

" Terminus
let g:TerminusCursorShape = 0

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

" Colorizer
" keep buffer colorized when you leave it
let g:colorizer_disable_bufleave = 1

" }}}

" vimrc override ---------------------- {{{

let s:vimrc_local = $HOME . '/.vim/vimrc.local'
if filereadable(s:vimrc_local)
  execute 'source ' . s:vimrc_local
endif

" }}}
