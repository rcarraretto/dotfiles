"# vim: set foldmethod=marker:

" Plugins ---------------------- {{{
set rtp+=/usr/local/opt/fzf

if exists('$DOTFILES_PRIVATE') && isdirectory($DOTFILES_PRIVATE . '/vim')
  set rtp+=$DOTFILES_PRIVATE/vim
endif

if exists('$DOTFILES_WORK') && isdirectory($DOTFILES_WORK . '/vim')
  set rtp+=$DOTFILES_WORK/vim
endif

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
Plug 'Valloric/YouCompleteMe', { 'commit': '4904077bec593da031a73c972dfc516544f72f78' }
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
" github support for fugitive
Plug 'tpope/vim-rhubarb'
" gitlab support for fugitive
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'cohama/agit.vim'
" debugging vim / vimscript
Plug 'tpope/vim-scriptease', { 'commit': '386f19cd92f7b30cd830784ae22ebbe7033564aa' }
" directory viewer (replaces netrw)
if !$USE_NETRW
  Plug 'justinmk/vim-dirvish'
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
Plug 'leafgarland/typescript-vim', { 'commit': '09cf6a6ecdef11cd32d38213093cfe86660255aa' }
Plug 'Quramy/tsuquyomi', { 'commit': '785af7476e0db2522372ef585c86947fc5625c81' }
Plug 'jparise/vim-graphql'
Plug 'peitalin/vim-jsx-typescript'
" Python
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" Golang
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'commit': '2855115efb1dd8a5f4436a80138633a1cb5d9f0c' }
" Applescript
Plug 'vim-scripts/applescript.vim'
" Handlebars
Plug 'mustache/vim-mustache-handlebars'
" Elixir
Plug 'elixir-lang/vim-elixir'
" Kotlin
Plug 'udalov/kotlin-vim'
" PowerShell
Plug 'PProvost/vim-ps1'

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

function! GetExtendedFileInfo() abort
  let str = ''
  " <SNR>
  if get(g:, 'statusline_show_ext_info', 0)
    let str .= printf(' | win %s', tabpagewinnr(tabpagenr()))
    let str .= printf(' | buf %s', bufnr())
    if &ft == 'vim' && &rtp =~ 'scriptease'
      let script_id = scriptease#scriptid('%')
      if empty(script_id)
        " e.g. script in autoload folder was not loaded yet
        let script_id = '?'
      endif
      let str .= printf(' | <SNR>%s', script_id)
    endif
  endif
  if &list == 0
    return str
  endif
  " fileencoding
  if !empty(&fileencoding)
    let str .= printf(' | %s', &fileencoding)
  endif
  " indentation
  let type = &expandtab ? '<space>' : '<tab>'
  if &softtabstop == 0
    if &tabstop == &shiftwidth
      let length = &tabstop
    else
      let length = printf('ts: %s sw: %s', &tabstop, &shiftwidth)
    endif
  else
    let length = printf('ts: %s sts: %s sw: %s', &tabstop, &softtabstop, &shiftwidth)
  endif
  let str .=  printf(' | %s %s', type, length)
  return str
endfunction

function! s:SetStatusline(...)
  if index(['diff', 'undotree'], &filetype) >= 0
    return
  endif
  setlocal statusline=
  let isActiveWindow = get(a:, 1, 1)
  if isActiveWindow && index(['help'], &filetype) == -1
    setlocal statusline+=%{GetCwdContext()}
  endif
  let showRelativeFilename = index(['qf', 'help'], &filetype) == -1
  if showRelativeFilename
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
  let showFlags = (index(['qf', 'help'], &filetype) == -1) && !get(b:, 'statusline_skip_flags')
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
    setlocal statusline+=%{GetExtendedFileInfo()}
    let showFt = (index(['qf', ''], &filetype) == -1) && !get(b:, 'statusline_skip_ft')
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

function! s:SetHighlight() abort
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

augroup AutoChangeKeyboardLayout
  autocmd!
  autocmd VimEnter,FocusGained,InsertLeave * call s:ToggleKeyboardLayout('switchToStandardKeyboardLayout')
  autocmd FocusLost,InsertEnter * call s:ToggleKeyboardLayout('switchToPreviousKeyboardLayout')
augroup END

if $USE_NETRW
  augroup CancelNetrw
    autocmd VimEnter * silent! autocmd! FileExplorer
  augroup END
endif

augroup FTOptions
  autocmd!
  autocmd FileType vim setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal textwidth=0 | call s:VimscriptMappings()
  autocmd FileType sh setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType text setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType markdown setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  " my own personal notes format
  autocmd FileType ntx setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
    \| setlocal foldmethod=marker
    \| setlocal commentstring=#\ %s
    \| setlocal nocursorline | let b:skip_cursor_line=1
    \| setlocal conceallevel=2 concealcursor=nvc
  autocmd FileType javascript setlocal foldmethod=indent | setlocal foldlevel=20 | setlocal formatoptions-=cro
  autocmd FileType typescript,typescript.tsx setlocal foldmethod=indent | setlocal foldlevel=20 | setlocal commentstring=//\ %s
  autocmd FileType json setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType yaml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType xml setlocal foldmethod=indent | setlocal foldlevel=20
  autocmd FileType lua setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType ruby setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab | setlocal foldlevel=20
  autocmd FileType c setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType cpp setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal expandtab
  autocmd FileType go call s:GolangMappings()
  autocmd FileType php setlocal shiftwidth=2 | setlocal tabstop=2 | setlocal foldmethod=indent | setlocal foldlevel=1
  autocmd FileType graphql setlocal shiftwidth=4 | setlocal tabstop=4 | setlocal expandtab | setlocal foldmethod=indent
  autocmd FileType applescript setlocal commentstring=--\ %s
  " Avoid "crontab: temp file must be edited in place".
  " https://vi.stackexchange.com/a/138/24815
  autocmd FileType crontab setlocal backupcopy=yes
  autocmd FileType haskell setlocal expandtab
  autocmd FileType matlab setlocal commentstring=%\ %s
  autocmd FileType netrw call s:NetrwMappings()
  autocmd FileType dirvish call s:DirvishConfig()
  autocmd FileType agit call s:AgitConfig()
  " when calling setqflist(), the status line is reset
  autocmd FileType qf call s:SetStatusline()
  autocmd FileType javascript,typescript,typescript.tsx,go,json,markdown,html,yaml,xml nnoremap <buffer> <leader>gp :Prettier<cr>
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
  autocmd BufNewFile,BufRead package.json call s:ConfPackageJsonBuffer()
augroup END

augroup SpecialFiles
  autocmd!
  autocmd BufRead /var/tmp/vim-messages.txt,/private/var/tmp/vim-messages.txt set ft=vim_log
    \| let b:skip_color_column=1
    \| let b:skip_cursor_line=1
    \| let b:parenmatch=0
    \| setlocal nonumber norelativenumber
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

" AutoCd {{{

function! s:AutoCd() abort
  let git_root = util#GetGitRoot({'full_path': 1})
  if empty(git_root)
    return
  endif
  let dotfiles = [
        \ $DOTFILES_PUBLIC,
        \ $DOTFILES_PRIVATE,
        \ $DOTFILES_WORK
        \ ]
  if index(dotfiles, git_root) >= 0 && get(g:, 'AUTO_CD_DOTFILES', 1) == 0
    " Log printf('AutoCd: skip dotfiles: %s', expand('%:p'))
    return
  endif
  " Log printf("AutoCd: lcd to %s (from %s) / file: %s", git_root, getcwd(), expand('%:p'))
  execute "lcd " . git_root
endfunction

augroup AutoCd
  autocmd!
  autocmd BufRead,BufNewFile ~/work/dotfiles/vim/bundle/*,$DOTFILES_PUBLIC/*,$DOTFILES_PRIVATE/*,$DOTFILES_WORK/* :call s:AutoCd()
augroup END

function! s:Cd(cd_cmd, cd_dir) abort
  let cmd = a:cd_cmd . ' ' . a:cd_dir
  execute cmd
  echo cmd
endfunction

function! s:CdToGitRoot(cd_cmd)
  let path = util#GetGitRoot()
  if empty(path)
    return util#error_msg("CdToGitRoot: couldn't find git root")
  endif
  call s:Cd(a:cd_cmd, path)
endfunction

function! s:CdToNodeJsRoot(cd_cmd) abort
  let path = util#GetNodeJsRoot()
  if empty(path)
    return util#error_msg("CdToNodeJsRoot: couldn't find package.json")
  endif
  call s:Cd(a:cd_cmd, path)
endfunction

function! s:CdToBufferDir(cd_cmd) abort
  " Expand to full path (:~) for better logs,
  " then get the directory (:h).
  let path = expand('%:~:h')
  if empty(path)
    return util#error_msg("CdToBufferDir: buffer doesn't have a disk path")
  endif
  call s:Cd(a:cd_cmd, path)
endfunction

" }}}

" Functions ---------------------- {{{

function! s:VimEnter()
  let g:original_cwd = getcwd()

  " Remove arguments from arglist.
  "
  " The arglist can be used by dirvish to select files,
  " so I prefer to start vim with an emtpy list.
  "
  " On startup, the arglist is populated with the path arguments.
  " So when starting vim with `vim .`, it's populated with the path
  " of the current directory.
  argdelete *

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

  " Overwrite eunuch.vim :Delete and :Remove
  command! Delete call s:DeleteCurrentFile()
  command! Remove Delete

  call writefile([], "/var/tmp/vim-messages.txt")
endfunction

" Use vim-compatible keyboard layout when in normal mode.
" When in insert mode, switch back to the original keyboard layout.
"
" https://stackoverflow.com/q/10983604/2277505
" Based on https://github.com/ironhouzi/bikey-vim/blob/master/plugin/bikey.vim
"
function! s:ToggleKeyboardLayout(hsFuncName) abort
  if !get(g:, 'auto_change_keyboard_layout', 1)
    return
  endif
  let out = system(printf("hs -c '%s()'", a:hsFuncName))
  if v:shell_error
    let g:auto_change_keyboard_layout = 0
    throw printf('%s: %s', a:hsFuncName, out)
  endif
endfunction

function! s:DisarmPluginGuard() abort
  for i in range(1, line('$'))
    let line = getline(i)
    " Skip empty lines
    if len(line) == 0
      continue
    endif
    " Skip comments
    if match(line, '^"') >= 0
      continue
    endif
    " Check if it's guarding a plugin.
    "
    " Example:
    " if exists('g:autoloaded_fugitive')
    "   finish
    " endif
    "
    let m = matchlist(line, '^if exists(''\(g:.*\)'')$')
    if empty(m)
      return 0
    endif
    if match(getline(i + 1), '^\s*finish$') == -1
      return 0
    endif
    let global_var_name = m[1]
    if !exists(global_var_name)
      return 0
    endif
    let cmd = "unlet " . global_var_name
    echom cmd
    execute cmd
    return global_var_name
  endfor
  return 0
endfunction

function! s:VimscriptMappings() abort
  nnoremap <buffer> <leader>ss :silent update <bar> call <sid>DisarmPluginGuard() <bar> source %<cr>
endfunction

" Adapted version of :GoDoc from vim-go:
" - When the popup is already open, close it
" - Set the popup to close with any cursor move
function! s:GoDocToggle() abort
  if empty(popup_list())
    GoDoc
    let popup_ids = popup_list()
    if empty(popup_ids)
      return
    endif
    call popup_setoptions(popup_ids[0], {'moved': 'any'})
  else
    call popup_clear()
  endif
endfunction

function! s:GolangMappings() abort
  nnoremap <buffer> <silent> K :call <sid>GoDocToggle()<cr>
  " vim-go
  " Remove :GoPlay command, as it uploads code to the internet
  " One could accidentally leak sensitive information
  if exists(':GoPlay')
    delcommand GoPlay
  endif
endfunction

function! s:SplitFromCount(count) abort
  if a:count == 1
    silent new
    return 1
  elseif a:count == 2
    silent vnew
    return 1
  elseif a:count == 3
    tabnew
    return 1
  endif
  return 0
endfunction

function! s:MaybeSplit() abort
  if v:count == 1
    silent split
    return 1
  elseif v:count == 2
    silent vsplit
    return 1
  elseif v:count == 3
    silent tab split
    return 1
  endif
  return 0
endfunction

function! s:YankLastMessage() abort
  let @* = util#messages()[0]
endfunction
command! Ym :call <sid>YankLastMessage()

" :Log {expr}
"
" Based on :PPmsg from scriptease
" ~/.vim/bundle/vim-scriptease/plugin/scriptease.vim:41:11
"
" Pretty print the value of {expr} using :echomsg
" Extended to also:
" - log to a special file
" - yank {expr} and result
"
" Example:
" :Log
" :Log 2 + 2
" :Log range(1, 5)
" :Log b:
"
" It has to be implemented inline in order for eval(<q-args>) and expand('<sfile>')
" to work properly.
"
" Variables inside the expression below are prefixed with underscore
" to avoid polluting the other function's scope.
" e.g. if the other function has a variable named 'lines', this could be a problem:
" Log lines
" == (expression is expanded) ==>
" let lines = []
" eval('lines')
"
command! -complete=expression -nargs=? Log
      \ let _lines = [] |
      \ let _is_error = 0 |
      \ try |
      \   if !empty(<q-args>) |
      \     let _lines = <sid>LogExprResult(eval(<q-args>)) |
      \   elseif !empty(expand('<sfile>')) |
      \     let _lines = [expand('<sfile>') . ', line ' . expand('<slnum>')] |
      \   endif |
      \ catch |
      \   let _lines = [matchstr(v:exception, 'Vim.*:\zsE\d\+: .*')] |
      \   let _is_error = 1 |
      \ endtry |
      \ call s:LogLines(_lines, {'qargs': <q-args>, 'sfile': expand('<sfile>'), 'is_error': _is_error})

function! s:LogExprResult(result) abort
  return split(scriptease#dump(a:result, {'width': &columns - 1}), "\n")
endfunction

function! s:LogLines(lines, opts) abort
  if empty(a:lines)
    " :Log on cmd-line without args
    return
  endif
  let qargs = get(a:opts, 'qargs', 0)
  let sfile = get(a:opts, 'sfile', 0)
  let is_error = get(a:opts, 'is_error', 0)
  for line in a:lines
    if is_error
      echohl ErrorMsg
      echomsg line
      echohl NONE
    else
      echomsg line
    endif
  endfor
  if empty(sfile)
    " Copy to clipboard, but only if :Log was called from cmd-line
    " (and not within a script).
    let @* = qargs . "\n> " . join(a:lines, "\n")
  endif
  let a:lines[0] = printf('[%s] %s', strftime('%H:%M:%S'), a:lines[0])
  call writefile(a:lines, "/var/tmp/vim-messages.txt", "a")
  call s:RefreshBuffer("/var/tmp/vim-messages.txt")
endfunction

function! s:RefreshBuffer(path) abort
  try
    " 'noautocmd' avoids:
    " "E218: autocommand nesting too deep"
    " when calling s:RefreshBuffer() from certain autocmds.
    " (more specifically, autocmd => :Log => s:RefreshBuffer())
    "
    execute 'noautocmd silent checktime ' . a:path
  catch /E93\|E94\|E523/
    " E93: More than one match for /some/path/
    "
    " E94: No matching buffer for /some/path/
    " Could happen with Dirvish buffers (a:path is a directory),
    "
    " E523: May not be allowed, when executing code in the context of autocmd.
    " For example, running :Log inside of s:SetStatusline().
  endtry
endfunction

" :GoToDefinition map <cr>
" :GoToDefinition function fzf#run
" :GoToDefinition hi typescriptFuncKeyword
function! s:GoToDefinition(cmd)
  " Sample verbose output:
  "
  " :verbose command TsuReload
  "     Name              Args Address Complete    Definition
  " b   TsuReload         *            buffer      :call tsuquyomi#reload(<f-args>)
  "         Last set from ~/work/tsuquyomi/autoload/tsuquyomi/config.vim line 185
  "     TsuReloadProject  0                        : call tsuquyomi#reloadProject()
  "         Last set from ~/work/tsuquyomi/plugin/tsuquyomi.vim line 91
  "
  let out = util#capture('verbose ' . a:cmd)
  let lines = split(out, '\n')
  for line in lines
    let m = matchlist(line, '.*Last set from \(.*\) line \(\d\+\)')
    if !len(m)
      continue
    endif
    let filename = m[1]
    let line_num = m[2]
    silent execute 'edit ' . filename
    execute line_num
    return
  endfor
  echo substitute(out, '\n', '', '')
endfunction
command! -nargs=1 GoToDefinition :call s:GoToDefinition(<q-args>)

" :GoToCommandDefinition AbortDispatch
function! s:GoToCommandDefinition(cmd)
  if a:cmd =~ '\s'
    echo 'Not a *command*: ' . a:cmd
    return
  endif
  call s:GoToDefinition('command ' . a:cmd)
endfunction
command! -nargs=1 -complete=command GoToCommandDefinition :call s:GoToCommandDefinition(<q-args>)

function! s:CaptureMessages()
  let messages = util#messages()
  silent call writefile(messages, '/var/tmp/test-results.txt')
  call s:RefreshBuffer('/var/tmp/test-results.txt')
  " open test-results.txt
  let a = util#OpenWindowInTab('/var/tmp/test-results.txt', 'vs')
  wincmd L
  wincmd p
endfunction
command! CaptureMessages call s:CaptureMessages()

function! s:VerboseToQfItems(cmd, text) abort
  let out = util#capture('verbose ' . a:cmd)
  let lines = split(out, '\n')
  let items = []
  for line in lines
    let m = matchlist(line, '.*Last set from \(.*\) line \(\d\+\)')
    if !len(m)
      continue
    endif
    let filename = fnamemodify(m[1], ':p')
    let lnum = m[2]
    call add(items, {'text': a:text, 'filename': filename, 'lnum': lnum})
  endfor
  if empty(items)
    return [{'text': a:text}]
  endif
  return items
endfunction

" Based on zS mapping from scriptease.vim
" scriptease#synnames()
function! s:DebugSynStack() abort
  let elems = reverse(map(synstack(line('.'), col('.')), 'synIDattr(v:val,"name")'))
  if empty(elems)
    return util#error_msg('DebugSynStack: no elements found in current line')
  endif
  let all_qf_items = []
  for elem in elems
    let qf_items = s:VerboseToQfItems('highlight ' . elem, elem)
    let all_qf_items += qf_items
  endfor
  call setqflist(all_qf_items)
  botright copen
endfunction
nnoremap <silent> <leader>zS :call <sid>DebugSynStack()<cr>

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
  " opendiff
  command! -buffer DirvishOpenDiff :call <sid>DirvishOpenDiff()
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

function! s:DirvishRename() abort
  let path = getline('.')
  let new_path = input('Moving ' . path . ' to: ', path, 'file')
  call rename(path, new_path)
  call s:DirvishRefresh()
endfunction

function! s:DirvishMkdir() abort
  let dirname = input('Mkdir: ')
  if !len(dirname)
    return
  endif
  let new_path = @% . dirname
  call mkdir(new_path)
  call s:DirvishRefresh()
endfunction

function! s:DirvishRm() abort
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
    let output = system('rm -r ' . fnameescape(path))
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
function s:DirvishImplode() abort
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
  let cmd = 'mv ' . fnameescape(path) . '* ' . fnameescape(@%) . ' && rmdir ' . fnameescape(path)
  let output = system(cmd)
  if v:shell_error
    echohl Error
    echom 'DirvishImplode: Error: ' . output
    echohl NONE
  endif
  call s:DirvishRefresh()
endfunction

function! s:ArgList() abort
  let i = 0
  let l = []
  while i < argc()
    call add(l, argv(i))
    let i = i + 1
  endwhile
  return l
endfunction

function! s:dirvish_path_shortname(path)
  if isdirectory(a:path)
    return "'" . fnamemodify(a:path[:-2], ':t') . "'"
  endif
  return "'" . fnamemodify(a:path, ':t') . "'"
endfunction

function! s:DirvishMv() abort
  let dirpath = getline('.')
  if !isdirectory(dirpath)
    let dirpath = fnamemodify(dirpath, ':h') . '/'
    if !isdirectory(dirpath)
      return util#error_msg('DirvishMv: target is not a directory: ' . dirpath)
    endif
  endif
  let cwd = getcwd() . '/'
  let filepaths = filter(s:ArgList(), 'filereadable(v:val) || (isdirectory(v:val) && v:val != cwd)')
  if len(filepaths) < 1
    return util#error_msg("DirvishMv: no file has been selected (use 'x' to select a file)")
  endif
  let filenames = map(copy(filepaths), 's:dirvish_path_shortname(v:val)')
  let dirname = s:dirvish_path_shortname(dirpath)
  if !util#prompt("Move " . join(filenames, ', ') . " to directory " . dirname . "? ")
    return
  endif
  let cmd = 'mv ' . join(map(filepaths, 'fnameescape(v:val)'), ' ') . ' ' . fnameescape(dirpath)
  let output = system(cmd)
  if v:shell_error
    call util#error_msg('DirvishMv: Error: ' . output)
  endif
  argdelete *
  execute "Dirvish " . dirpath
endfunction

function! s:DirvishOpenDiff() abort
  let filepaths = filter(s:ArgList(), 'filereadable(v:val)')
  if len(filepaths) < 1
    return util#error_msg("DirvishOpenDiff: no file has been selected (use 'x' to select a file)")
  endif
  if len(filepaths) == 1
    return util#error_msg("DirvishOpenDiff: only one file has been selected")
  endif
  let filenames = map(copy(filepaths), 's:dirvish_path_shortname(v:val)')
  if !util#prompt("Diff " . join(filenames, ', ') . "? ", {'type': 'info'})
    return
  endif
  let cmd = 'opendiff ' . join(map(filepaths, 'fnameescape(v:val)'), ' ')
  let output = system(cmd)
  if v:shell_error
    return util#error_msg('DirvishOpenDiff: Error: ' . output)
  endif
endfunction

" Based on eunuch.vim :Delete
function! s:DeleteCurrentFile() abort
  let absolute_path = expand('%:p')
  if empty(absolute_path)
    " e.g. :new
    return util#error_msg('DeleteCurrentFile: Buffer does not have a path')
  endif
  if isdirectory(absolute_path)
    " e.g. dirvish buffer
    return util#error_msg('DeleteCurrentFile: Buffer cannot be a directory')
  endif
  if !filereadable(absolute_path)
    " e.g.
    " :new path/to/file
    " :Remove
    return util#error_msg('DeleteCurrentFile: Buffer is not associated to a file in disk')
  endif
  " Use bwipeout instead of bdelete.
  " This way, another file can be renamed to have the name of the deleted file.
  " Else s:RenameFile() causes 'A buffer with that name already exists'.
  bwipeout
  if delete(absolute_path)
    return util#error_msg('DeleteCurrentFile: Failed to delete "' . absolute_path . '"')
  endif
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
    call system("open " . shellescape(url))
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
    " update setting globally for new buffers
    set norelativenumber
  else
    call s:GlobalWinDo('s:SetRelativeNumber')
    " update setting globally for new buffers
    set relativenumber
  endif
endfunction

function! s:ToggleListChars()
  if &list
    setlocal nolist
  else
    setlocal list
  endif
endfunction

function! s:ToggleCursorFocusIndicators() abort
  let updated1 = util#ToggleGlobalVar('skip_cursor_line')
  let updated2 = util#ToggleGlobalVar('skip_color_column')
  echom printf("ToggleCursorFocusIndicators: %s %s", updated1, updated2)
endfunction

function! s:ShouldColorColumn()
  if get(g:, 'skip_color_column')
    return 0
  endif
  if get(b:, 'skip_color_column')
    return 0
  endif
  return index(['qf', 'diff', 'undotree', 'agit', 'agit_stat', 'agit_diff', 'rc_git_log', 'rc_git_branches', 'rc_git_diff', 'fugitive', 'fugitiveblame'], &filetype) == -1
endfunction

function! s:ShouldCursorLine()
  if get(g:, 'skip_cursor_line')
    return 0
  endif
  if get(b:, 'skip_cursor_line')
    return 0
  endif
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
  else
    let &l:colorcolumn='0'
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
  if get(b:, 'skip_trim_whitespace')
    return
  endif
  let save_cursor = getpos('.')
  if &ft == 'markdown'
    " Keep 2 trailing whitespaces.
    "
    " https://daringfireball.net/projects/markdown/syntax#p
    "
    " "When you do want to insert a <br /> break tag using Markdown, you end a line
    " with two or more spaces, then type return."
    "
    %s/\(^\s\+$\|\S\zs\s$\|\S\zs\s\{3,\}$\)//e
  else
    %s/\s\+$//e
  endif
  call setpos('.', save_cursor)
endfunction

function! s:MoveToPrevParagraph()
  let former_line = line('.')
  " if in the middle of paragraph
  if len(getline(line('.') - 1))
    normal! {
    if line('.') == 1
      return
    endif
    normal! +
    " Sometimes doing {+ makes it go back to
    " the same line, when using folding and when
    " there are paragraphs inside the fold.
    if line('.') == former_line
      normal! {
    endif
    return
  end
  " if current line is empty
  if len(getline('.')) == 0
    normal! {
    if line('.') == 1
      return
    endif
    normal! +
    return
  end
  " if on the beginning of paragraph
  normal! {{
  if line('.') == 1
    return
  endif
  normal! +
endfunction

function! s:MoveToNextParagraph()
  if len(getline('.')) == 0
    normal! +
    return
  end
  normal! }+
endfunction

function! s:OpenInSourceTree()
  let output = util#GetGitRoot()
  if empty(output)
    echohl ErrorMsg
    echom "OpenInSourceTree: couldn't find git root"
    echohl NONE
    return
  endif
  call system('open -a SourceTree ' . fnameescape(output))
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

" Similar to star (*) but for arbitrary motions,
" instead of just the word under cursor.
function! s:SearchOperator(type)
  let @/ = s:YankOperatorTarget(a:type)
  call feedkeys(":let &hlsearch=1 \| echo\<cr>", "n")
endfunction

function! s:GrepOperator(type)
  let target = s:YankOperatorTarget(a:type)
  silent execute "Ag -Q --hidden " . shellescape(target)
endfunction

function! s:GrepOperatorInGitRoot(type)
  let target = s:YankOperatorTarget(a:type)
  call s:SearchInGitRoot(target)
endfunction

function! s:YankOperatorTarget(type) abort
  if a:type ==# 'v'
    execute "normal! `<v`>y"
  elseif a:type ==# 'char'
    execute "normal! `[v`]y"
  else
    return
  endif
  return @@
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
  let oldfile = expand('%:p')
  let newfile = fnamemodify(a:name, ':p')
  if oldfile == newfile
    return util#error_msg('RenameFile: renaming to the same file')
  endif
  if bufexists(newfile)
    return util#error_msg('RenameFile: A buffer with that name already exists')
  endif

  let v:errmsg = ''
  silent! execute 'saveas ' . a:name
  if v:errmsg !~# '^$\|^E329'
    echoerr v:errmsg
    return
  endif

  if expand('%:p') == oldfile || !filewritable(expand('%:p'))
    return util#error_msg('RenameFile: Rename failed for some reason')
  endif

  let lastbufnr = bufnr('$')
  if fnamemodify(bufname(lastbufnr), ':p') == oldfile
    silent execute lastbufnr . 'bwipe!'
  else
    return util#error_msg('RenameFile: Could not wipe out the old buffer for some reason')
  endif

  if delete(oldfile) != 0
    return util#error_msg('RenameFile: Could not delete the old file: ' . oldfile)
  endif
endfunction

command! -nargs=1 -complete=file RenameFile call s:RenameFile(<q-args>)

function! s:CloseAuxiliaryBuffers() abort
  cclose
  lclose
  " close buffers in /var/tmp:
  " - test-results.txt
  " - test-console.txt
  " - vim-messages.txt
  let bufs = filter(getbufinfo(), {idx, val -> val['listed'] && val['name'] =~ '^/private/var/tmp'})
  let bufnrs = map(bufs, 'v:val.bufnr')
  for bufnr in bufnrs
    execute "bdelete " . bufnr
  endfor
endfunction

function! s:DispatchAndLogOutput(cmd) abort
  silent execute printf("Dispatch! %s |& tee /var/tmp/test-results.txt /var/tmp/test-console.txt", a:cmd)
endfunction

function! s:EditSketchBuffer(ft)
  let configs = {
  \  'typescript': {
  \    'path': $DOTFILES_PRIVATE . '/src/sketch.ts',
  \    'cmd': 'ts-node --project $DOTFILES_PRIVATE/tsconfig.json %'
  \  },
  \  'javascript': {
  \    'path': $DOTFILES_PRIVATE . '/src/sketch.js',
  \    'cmd': 'node %'
  \  },
  \  'go': {
  \    'path': $DOTFILES_PRIVATE . '/src/sketch.go',
  \    'cmd': 'go run %'
  \  }
  \}
  if !has_key(configs, a:ft)
    return util#error_msg(printf('EditSketchBuffer: unsupported filetype: %s', a:ft))
  endif
  let config = configs[a:ft]
  call util#EditFile(config['path'])
  execute "nnoremap <buffer> <space>t :update <bar> call <sid>DispatchAndLogOutput('" . config['cmd'] . "')<cr>"
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

function! s:ExploreProject(edit_cmd, selection) abort
  let path = a:selection[0]
  execute a:edit_cmd . ' ' . path . " | lcd " . path
  " Somehow the statusline doesn't get properly rendered,
  " when calling this from FzfExploreProject().
  call s:SetStatusline()
endfunction

function! s:FzfExploreProject() abort
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
        \ '': function('s:ExploreProject', ['edit']),
        \ 'ctrl-t': function('s:ExploreProject', ['tabedit']),
        \ 'ctrl-x': function('s:ExploreProject', ['split']),
        \ 'ctrl-v': function('s:ExploreProject', ['vsplit']),
        \ }
  call s:FzfWithAction({'source': a:cmd}, action)
endfunction

function! s:FzfWithAction(opts, action) abort
  let opts = a:opts
  let opts['down'] = '~40%'
  " Put custom actions, instead of using g:fzf_action.
  " This is based on fzf#wrap().
  let opts._action = a:action
  if !has_key(opts, 'options')
    let opts.options = []
  endif
  call add(opts.options, '--expect')
  call add(opts.options, join(keys(opts._action), ','))
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

function! s:FzfCurrentFolderNonRecursive(folder) abort
  " https://unix.stackexchange.com/a/104803
  let cmd = '(cd ' . fnameescape(a:folder) . ' && find . -mindepth 1 -maxdepth 1 -type f | cut -c 3-)'
  let prompt = '[CurrentFolder] ' . a:folder . '/'
  function! s:FzfCurrentFolderEdit(edit_cmd, selection) abort closure
    let path = a:folder . '/' . a:selection[0]
    execute a:edit_cmd . ' ' . path
  endfunction
  let action = {
        \ '': function('s:FzfCurrentFolderEdit', ['edit']),
        \ 'ctrl-t': function('s:FzfCurrentFolderEdit', ['tabedit']),
        \ 'ctrl-x': function('s:FzfCurrentFolderEdit', ['split']),
        \ 'ctrl-v': function('s:FzfCurrentFolderEdit', ['vsplit']),
        \ }
  call s:FzfWithAction({'source': cmd, 'options': ['--prompt', prompt]}, action)
endfunction

function! s:SearchNotes(input) abort
  execute printf('Ag --hidden -Q %s -G "\.txt$" %s', s:AgBuildPattern(a:input), s:GetNoteDirs())
endfunction
command! -nargs=* SearchNotes call s:SearchNotes(<q-args>)

function! s:FzfNotes() abort
  let cmd = 'find ' . s:GetNoteDirs() . ' -type f -name "*.txt" | sed "s|^$HOME|~|"'
  call fzf#run(fzf#wrap({'source': cmd, 'options': ['--prompt', '[notes*] ']}))
endfunction

function! s:GetNoteDirs() abort
  let dirs = ['~/Dropbox/notes/']
  if isdirectory($HOME . '/Dropbox/notes-home')
    call add(dirs, '~/Dropbox/notes-home')
  endif
  if exists('$NOTES_WORK') && isdirectory($NOTES_WORK)
    call add(dirs, fnameescape($NOTES_WORK))
  endif
  return join(dirs, ' ')
endfunction

function! s:SearchDotfiles(input) abort
  execute printf("Ag --hidden -Q %s %s", s:AgBuildPattern(a:input), s:GetDotfilesDirs())
endfunction
command! -nargs=* SearchDotfiles :call <sid>SearchDotfiles(<q-args>)

function! s:FzfDotfiles() abort
  let cmd = 'ag -g "" --hidden ' . s:GetDotfilesDirs() . ' | sed "s|^$HOME|~|"'
  call fzf#run(fzf#wrap({'source': cmd, 'options': ['--prompt', '[dotfiles*] ']}))
endfunction

function! s:GetDotfilesDirs() abort
  let dirs = [$DOTFILES_PUBLIC, $DOTFILES_PRIVATE]
  if exists('$DOTFILES_WORK') && isdirectory($DOTFILES_WORK)
    call add(dirs, fnameescape($DOTFILES_WORK))
  endif
  return join(dirs, ' ')
endfunction

function! s:SearchInGitRoot(input) abort
  let path = util#GetGitRoot()
  if empty(path)
    let path = util#GetGitRoot({'path': getcwd()})
  endif
  if empty(path)
    return util#error_msg('SearchInGitRoot: Git root not found')
  endif
  execute printf('Ag --hidden -Q %s %s', s:AgBuildPattern(a:input), path)
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
  if !empty(a:input)
    execute printf('Ag -Q %s %s', s:AgBuildPattern(a:input), path)
  else
    " Use s:AgVimgrep instead of :Ag to bypass calling s:AgSetHighlight,
    " which is buggy.
    call s:AgVimgrep(printf('%s %s', s:AgSearchFromSearchReg(), path))
  endif
  cfirst
endfunction
command! -nargs=* SearchInFile :call <sid>SearchInFile(<q-args>)

function! s:SysOpen(filename)
  let filename = a:filename
  if empty(a:filename)
    if &ft == 'dirvish'
      let filename = fnameescape(getline('.'))
    else
      let filename = expand('%')
    endif
  endif
  if isdirectory(filename)
    return util#error_msg('SysOpen: selected path cannot be a directory')
  endif
  let ext = fnamemodify(filename, ':e')
  if index(['sh'], ext) != -1
    echo 'SysOpen: unsupported extension: ' . ext
    return
  endif
  let output = system('open ' . filename)
  if v:shell_error
    echo 'Error: ' . substitute(output, '\n', ' ', 'g')
    return
  endif
endfunction
command! -nargs=? -complete=file SysOpen call s:SysOpen(<q-args>)

function! s:OpenFolderInFinder() abort
  let dir = expand('%:p:h')
  if !isdirectory(dir)
    return util#error_msg('OpenFolderInFinder: not a folder: ' . dir)
  endif
  echom "OpenFolderInFinder: " . dir
  call system("open -a Finder " . fnameescape(dir))
endfunction
command! OpenFolderInFinder call s:OpenFolderInFinder()

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

" Similar to :%!cmd (:h :range!)
" but do not replace the contents of buffer in case of error
function! s:FilterBufferOrFail(cmd) abort
  let input = join(getline(0, '$'), "\n")
  let output = system(a:cmd, input)
  if v:shell_error
    call util#error_msg(printf("FilterBufferOrFail: %s\n%s", a:cmd, output))
  else
    call setline(1, split(output, "\n"))
  endif
  return output
endfunction

function! s:Prettier() abort
  let prettier_parsers={
  \ 'json': 'json',
  \ 'javascript': 'babel',
  \ 'typescript': 'typescript',
  \ 'typescript.tsx': 'typescript',
  \ 'markdown': 'markdown',
  \ 'html': 'html',
  \ 'yaml': 'yaml'
  \}
  let adhoc_fts = ['xml', 'go']
  let supported_ft = has_key(prettier_parsers, &ft) || index(adhoc_fts, &ft) >= 0

  if !supported_ft
    return util#error_msg('Prettier: Unsupported filetype: ' . &ft)
  endif

  let save_pos = getpos('.')
  silent! update

  if has_key(prettier_parsers, &ft)
    let parser = prettier_parsers[&ft]
    let opts = ''
    " Try to find .prettierrc.json upwards until the git root.
    " This would be an evidence that the project uses prettier.
    let prettierrc_json = findfile('.prettierrc.json', '.;' . util#GetGitRoot())
    if empty(prettierrc_json)
      " Use global prettier config for example in sketch buffers or
      " projects that don't have prettier installed.
      let opts = "--config=" . $DOTFILES_PRIVATE . "/.prettierrc "
    endif
    execute "%!npx prettier " . opts . "--parser=" . parser
  else
    if &ft == 'xml'
      " https://stackoverflow.com/a/16090892
      let cmd = "python -c 'import sys;import xml.dom.minidom;s=sys.stdin.read();print(xml.dom.minidom.parseString(s).toprettyxml())'"
      call s:FilterBufferOrFail(cmd)
    elseif &ft == 'go'
      call system('go fmt ' . expand('%:p'))
      silent checktime
      return
    else
      return util#error_msg('Unimplemented filetype: ' . &ft)
    endif
  endif

  call setpos('.', save_pos)
  silent! update
endfunction
command! Prettier call s:Prettier()

function! s:HighestWinnr()
  let wins = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == tabpagenr()')
  return wins[-1]['winnr']
endfunction

function! s:CycleWinDownOrNext() abort
  let prev_winnr = winnr()
  wincmd j
  if prev_winnr == winnr()
    " Can move from B to C
    "   A  |  C
    " -----|
    "  *B* |
    "
    wincmd w
  endif
endfunction

function! s:CycleWinUpOrPrev() abort
  let prev_winnr = winnr()
  wincmd k
  if prev_winnr == winnr()
    " Can move from C to B
    " ('wincmd h' will move from C to A sometimes, depending on
    "  where you are on C)
    "   A  | *C*
    " -----|
    "   B  |
    "
    wincmd W
  endif
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

function! s:AgVimgrep(args) abort
  call s:StatelessGrep('ag --vimgrep', '%f:%l:%c:%m,%f:%l:%m', a:args)
endfunction

function! s:AgSetHighlight(args) abort
  " Note: This does not properly translate an 'ag' pattern to a vim regex.
  " e.g. \bbatata\b should become \<batata\>
  let @/ = matchstr(a:args, "\\v(-)\@<!(\<)\@<=\\w+|['\"]\\zs.{-}\\ze['\"]")
  call feedkeys(":let &hlsearch=1 \| echo\<cr>", "n")
endfunction

function! s:AgSearchFromSearchReg() abort
  let search = getreg('/')
  " translate vim regular expression to perl regular expression.
  let search = substitute(search, '\(\\<\|\\>\)', '\\b', 'g')
  return '"' . search . '"'
endfunction

" It seems like the search pattern should be surrounded with single quotes
" instead of double quotes.
"
" Else the following search terms wouldn't work: "$#" and "$@".
" I think these would be interpreted by the shell, when in double quotes.
function! s:AgBuildPattern(input) abort
  return printf("'%s'", a:input)
endfunction

" :Ag command.
" Based on ack.vim (ack#Ack)
function! s:Ag(args) abort
  if empty(a:args)
    return s:AgVimgrep(s:AgSearchFromSearchReg())
  endif
  call s:AgVimgrep(a:args)
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
  call s:MaybeSplit()
  cfirst
endfunction

" Get full paths from :scriptnames
function! s:GetScriptPaths() abort
   return map(split(execute('scriptnames'), "\n"), 'fnamemodify(substitute(v:val, ''^\s*\d*: '', "", ""), '':p'')')
endfunction

function! s:ResetFoldLevel()
  if index(['ntx', 'pem'], &ft) >= 0
    setlocal foldlevel=0
  else
    setlocal foldlevel=1
  endif
  normal! zz
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

" Based on https://stackoverflow.com/a/38735392/2277505
function! s:ListCtrlMappings() abort
  let out = util#capture('map')
  vnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  silent put =out
  silent v/^.  <C-/d
  sort
endfunction
command! ListCtrlMappings :call <sid>ListCtrlMappings()

function! s:CaptureRuntime() abort
  " &rtp with removed leading \n
  let rtp = util#capture('echo &rtp')[1:]
  let paths = split(rtp, ',')
  let items = map(paths, "{'filename': v:val}")
  call setqflist(items)
  botright copen
endfunction
command! CaptureRuntime :call <sid>CaptureRuntime()

function! s:CopyCursorReference() abort
  let path = fnameescape(expand("%:~"))
  let line_num = line('.')
  let col_num = col('.')
  let @* = printf('%s:%s:%s', path, line_num, col_num)
endfunction

function! s:GoToCursorReference() abort
  let line = getline('.')
  let cursor = getpos('.')
  try
    let did_split = s:MaybeSplit()
    normal! gf
  catch /E447/
    if did_split
      quit
    endif
    let msg = 'GoToCursorReference: ' . matchstr(v:exception, 'Vim(normal):E447: \zs\(.*\)')
    return util#error_msg(msg)
  endtry
  let jumped_filename = expand('%:t')
  " [Note]
  " Use 'very nomagic' (\V) so that the filename is not interpreted as a regex
  " https://stackoverflow.com/a/11311701/2277505
  let regex = '\V' . jumped_filename . ':\(\d\+\)\(:\(\d\+\)\)\?'
  let matches = matchlist(line, regex)
  if empty(matches)
    return
  endif
  let target_line = matches[1]
  let target_col = matches[3]
  call cursor(target_line, target_col)
  try
    " Open folds
    normal! zO
  catch /E490/
    " No fold found
  endtry
endfunction

function! s:CopyCmdline() abort
  " If it's a :Log command, then don't include the 'Log ' part.
  " For example:
  " > Log strftime('%H:%M:%S')
  " copies
  " > strftime('%H:%M:%S')
  let @* = matchstr(getcmdline(), '^\(Log \)\?\zs.*')
  return ""
endfunction

" Open/close a log window on the right side of the current tab
" and keep all other log windows closed.
function! s:ToggleLogWindow(target_path) abort
  let paths = [
        \'/var/tmp/test-console.txt',
        \'/var/tmp/test-results.txt',
        \'/var/tmp/vim-messages.txt'
        \]
  let oldwinnr = winnr()
  let opened = util#ToggleWindowInTab(a:target_path)
  if opened == 1
    " Window was opened.
    " Keep window on the right side.
    wincmd L
    setlocal wrap
    setlocal foldlevel=20
    " Close all the other log windows.
    for path in paths
      if path != a:target_path
        call util#CloseWindowInTab(path)
      endif
    endfor
  endif
  " Go back to original window
  if winbufnr(oldwinnr) != -1
    execute oldwinnr . "wincmd w"
  endif
endfunction

" Given the current search term, show the uniques matches.
" Based on https://vi.stackexchange.com/a/8914
function! s:ShowUniqueSearchMatches() abort
  let matches = []
  silent execute '%s//\=add(matches, submatch(0))/nge'
  if empty(matches)
    return util#error_msg('ShowUniqueSearchMatches: no matches: ' . @/)
  endif
  call uniq(sort(matches))
  let str = join(matches, "\n")
  " Open buffer with results
  new
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  noautocmd silent! 1put= str
  noautocmd silent! 1delete _
  call feedkeys(":nohlsearch\<cr>")
endfunction
command! ShowUniqueSearchMatches :call <sid>ShowUniqueSearchMatches()

function! s:ViewFormattedJson(str, split_count) abort
  let str = a:str
  " remove line feed at the end
  if char2nr(str[-1:-1]) == 10
    let str = str[:-2]
  endif
  " replace null character by newline
  let str = substitute(str, '\%x00', '\r', 'g')
  " remove carriage return character (CTRL-V + <cr>)
  let str = substitute(str, '\r', '', 'g')
  " handle stringified json
  if (str[0] == '"' && str[-1:] == '"') || str =~ '^\[\?{\\"'
    if str[0] == '"' && str[-1:] == '"'
      " remove surrounding double quotes
      let str = str[1:-2]
    endif
    " unescape double quotes
    let str = substitute(str, '\\"', '"', 'g')
  endif
  call s:SplitFromCount(a:split_count)
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  let b:skip_color_column = 1
  call setline(1, str)
  set ft=json
  silent %!python -m json.tool
  if v:shell_error
    call setline(1, str)
    return util#error_msg('ViewFormattedJson: invalid json')
  endif
  nnoremap <buffer> K :call <sid>PreviewJsonFieldValue()<cr>
endfunction

command! -count=3 JsonFromClipboard call s:ViewFormattedJson(getreg('*'), <count>)

" Sees prettified version of:
" - stringified json
" - string containing \n
function! s:PreviewJsonFieldValue() abort
  let matches = matchlist(getline('.'), '^\s*"[^"]\+": "\(.*\)"')
  if empty(matches)
    return util#error_msg('PreviewJsonFieldValue: could not extract value')
  endif
  let value = matches[1]
  let split_count = 1
  if value[0] == '{'
    call s:ViewFormattedJson(value, split_count)
    return
  endif
  call s:SplitFromCount(split_count)
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  let b:skip_color_column = 1
  call setline(1, split(value, '\\n'))
endfunction

function! s:CloseUnlistedBuffersInTab() abort
  let wins = filter(getwininfo(), '!v:val.quickfix && v:val.tabnr == tabpagenr()')
  for win in wins
    if getbufinfo(win['bufnr'])[0]['listed'] == 0
      call win_gotoid(win['winid'])
      noautocmd wincmd c
    endif
  endfor
endfunction

function! s:PreviewJsonLine() abort
  call s:CloseUnlistedBuffersInTab()
  call s:ViewFormattedJson(getline('.'), 2)
  noautocmd wincmd p
  noautocmd 50 wincmd |
endfunction

function! s:TogglePreviewJsonLines() abort
  let preview_json_lines = util#ToggleBufVar('preview_json_lines')
  if preview_json_lines == 0
    augroup AutoPreviewJsonLine
      autocmd!
    augroup END
    call s:CloseUnlistedBuffersInTab()
    return
  endif
  augroup AutoPreviewJsonLine
    autocmd!
    let s:save_ut = &updatetime
    autocmd CursorMoved <buffer> set updatetime=100
    autocmd CursorHold <buffer> call s:PreviewJsonLine()
    autocmd BufLeave <buffer> let &updatetime = s:save_ut
  augroup END
  call s:PreviewJsonLine()
endfunction
command! TogglePreviewJsonLines call s:TogglePreviewJsonLines()

function! s:JavascriptFromClipboard() abort
  silent tabedit
  silent put! *
  silent execute '%!prettier --parser=babel'
  set ft=javascript
endfunction
command! JavascriptFromClipboard :call <sid>JavascriptFromClipboard()

function! s:UnpackJsonStr(str) abort
  let str = a:str[1:-2]
  let str = substitute(str, '\\"', '"', 'g')
  let str = substitute(str, '\\n', "\n", 'g')
  return str
endfunction

" Opens a scratch buffer with the contents of the clipboard.
" Formats content if possible.
function! s:BufferFromClipboard(ft, split_count) abort
  call s:SplitFromCount(a:split_count)
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  let str = trim(getreg('*'))
  if a:ft == 'xml' && str[0] == '"' && str[-1:] == '"'
    let str = s:UnpackJsonStr(str)
  endif
  call setline(1, str)
  let &ft = a:ft
  Prettier
endfunction
command! -nargs=1 -count=3 BufferFromClipboard call s:BufferFromClipboard(<q-args>, <count>)

" Based on:
" https://stackoverflow.com/a/3264176
" https://vim.fandom.com/wiki/Search_only_over_a_visual_range
function! s:SearchInFold() abort
  let pos = getpos('.')
  normal! [z
  let start = line('.')
  normal! ]z
  let end = line('.')
  call setpos('.', pos)
  " :help \%>l
  " :help \%<l
  let after_start = '\%>' . start . 'l'
  let before_end = '\%<' . end . 'l'
  call feedkeys('/' . after_start . before_end)
endfunction

function! s:YankNpm() abort
  let matches = matchlist(getline('.'), '^\s*"\([^"]*\)": "^\?\([^"]*\)",')
  if empty(matches)
    return util#error_msg('YankNpm: pattern not found')
  endif
  let npm = matches[1] . '@' . matches[2]
  let @* = npm
  echom npm
endfunction

function! s:ConfPackageJsonBuffer() abort
  command! -buffer YankNpm :call <sid>YankNpm()
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

" Show output of last command
nnoremap K :!<cr>

" Move between paragraphs.
" Similar to vim's { and }, but jumps to the first line of paragraph,
" instead of to an empty line.
nnoremap <silent> { :call <sid>MoveToPrevParagraph()<cr>
nnoremap <silent> } :call <sid>MoveToNextParagraph()<cr>

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
nnoremap <silent> <tab> :call <sid>ToggleFolding()<cr>
nnoremap <f6> <c-i>

" Reset foldlevel to 1
nnoremap <silent> zf :call <sid>ResetFoldLevel()<cr>

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
" Toggle showing extended info in statusline
nnoremap <silent> cos :call util#ToggleGlobalVar('statusline_show_ext_info')<cr>
" Toggle color column
nnoremap <silent> coc :call util#ToggleBufVar('&colorcolumn', {'print': 1, 'on_value': '80,100'})<cr>
" Toggle cursor column
nnoremap <silent> cox :call util#ToggleBufVar('&cursorcolumn', {'print': 1})<cr>
" Toggle cursor focus indicators (global)
nnoremap <silent> yox :call <sid>ToggleCursorFocusIndicators()<cr>
" Toggle trim whitespace
command! ToggleTrimWhitespace :call util#ToggleBufVar('skip_trim_whitespace', {'print': 1})
" Toggle conceal
command! ToggleConceal :call util#ToggleBufVar('&conceallevel', {'print': 1, 'off_value': '0', 'on_value': '3'})

" Windows
" window navigation
nnoremap <silent> <space>j :call <sid>CycleWinDownOrNext()<cr>
nnoremap <silent> <space>k :call <sid>CycleWinUpOrPrev()<cr>
nnoremap <silent> <space>h :call <sid>CycleWinLeft()<cr>
nnoremap <silent> <space>l :call <sid>CycleWinRight()<cr>
nnoremap <space>; <c-w>p
nnoremap <space>w <c-w><c-w>
" close window
nnoremap <space>q :q<cr>
nnoremap <space>Q :bd!<cr>
" decrease window size
nnoremap <space>, :20wincmd <<cr>
" increase window size
nnoremap <space>. :20wincmd ><cr>

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
" Copy current command-line
cnoremap <expr> <c-x>y <sid>CopyCmdline()

" Vimscript, vim debug
nnoremap <leader>ev :<c-u>call util#EditFile(resolve($MYVIMRC))<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" yank last message
nnoremap <leader>ym :Ym<cr>
" :Log {expr}
nnoremap <space>v :Log<space>
" reload syntax highlighting
nnoremap <leader>sy :syntax clear <bar> syntax on<cr>
" capture :messages in a file
nnoremap <space>z :CaptureMessages<cr>

" Browse files & search
" quickly edit some files and folders
nnoremap <leader>el :<c-u>call util#EditFile($DOTFILES_PRIVATE . '/vimrc.local')<cr>
nnoremap <leader>ess :<c-u>call <sid>MaybeSplit() <bar> UltiSnipsEdit<cr>
nnoremap <leader>esp :e $DOTFILES_PRIVATE/vim/UltiSnips/<c-r>=&filetype<cr>.snippets<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :<c-u>call util#EditFileUpwards(".todo")<cr>
nnoremap <leader>en :<c-u>call <sid>FzfNotes()<cr>
nnoremap <leader>ei :<c-u>call util#EditFile("~/Dropbox/notes/dev/dev.txt")<cr>
nnoremap <leader>em :<c-u>call util#EditFile($DOTFILES_PRIVATE . '/README.md')<cr>
nnoremap <leader>eb :<c-u>call util#EditFile($DOTFILES_PRIVATE . '/bashrc.local')<cr>
if exists('$NOTES_WORK')
  nnoremap <leader>ew :<c-u>call util#EditFile($NOTES_WORK . "/work.txt")<cr>
endif
nnoremap <leader>ek :call <sid>EditSketchBuffer(&ft)<cr>
nnoremap <leader>ep :call <sid>FzfExploreProject()<cr>
" explore syntax files for the current filetype
nnoremap <leader>ey :<c-u>call <sid>ExploreSyntaxFiles()<cr>
" browse files
nnoremap <space>o :WrapCommand Files<cr>
" browse files under version control
nnoremap <space>O :GFiles<cr>
" browse original cwd
nnoremap <leader>oo :execute "Files " . g:original_cwd<cr>
" browse current folder (non-recursive)
nnoremap <leader>of :call <sid>FzfCurrentFolderNonRecursive(expand("%:h"))<cr>
" browse history
nnoremap <space>m :WrapCommand FzfHistory<cr>
" browse dotfiles
nnoremap <leader>od :call <sid>FzfDotfiles()<cr>
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
" browse /var/tmp
nnoremap <leader>ot :Files /var/tmp<cr>
" browse commands
" (<c-x> executes the command directly)
nnoremap <space>c :Commands<cr>
" browse command-line history
nnoremap <space>: :History:<cr>
" search in project
nnoremap <space>a :Ag --hidden -Q ''<left>
" search in git root
nnoremap <space>A :SearchInGitRoot<space>
" search operator
nnoremap g/ :set operatorfunc=<sid>SearchOperator<cr>g@
" grep operator
nnoremap <space>g :set operatorfunc=<sid>GrepOperator<cr>g@
vnoremap <space>g :<c-u>call <sid>GrepOperator(visualmode())<cr>
nnoremap <space>G :set operatorfunc=<sid>GrepOperatorInGitRoot<cr>g@
vnoremap <space>G :<c-u>call <sid>GrepOperatorInGitRoot(visualmode())<cr>
" search in file (from visual mode)
xnoremap * :<c-u>call <sid>VisualStar('/')<cr>/<c-r>=@/<cr><cr>
xnoremap # :<c-u>call <sid>VisualStar('?')<cr>?<c-r>=@/<cr><cr>
" search fold markers in buffer
" hack:
"   typing '{' 3 times creates a fold marker in this vimrc.
"   close it with a comment after the mapping.
"   https://stackoverflow.com/a/24717020
nnoremap <space>/f :BLines {{{$<cr>| " }}}
nnoremap <space>/z :call <sid>SearchInFold()<cr>
" change directory
nnoremap <silent> <leader>cg :call <sid>CdToGitRoot('lcd')<cr>
nnoremap <silent> <leader>cG :call <sid>CdToGitRoot('cd')<cr>
nnoremap <silent> <leader>cn :call <sid>CdToNodeJsRoot('lcd')<cr>
nnoremap <silent> <leader>cN :call <sid>CdToNodeJsRoot('cd')<cr>
nnoremap <silent> <leader>cb :call <sid>CdToBufferDir('lcd')<cr>
nnoremap <silent> <leader>cB :call <sid>CdToBufferDir('cd')<cr>
" change to previous current directory
nnoremap <silent> <leader>cc :cd - <bar> pwd<cr>
" toggle log windows
nnoremap <leader>2 :call <sid>ToggleLogWindow('/var/tmp/test-console.txt')<cr>
nnoremap <leader>3 :call <sid>ToggleLogWindow('/var/tmp/test-results.txt')<cr>
nnoremap <leader>4 :call <sid>ToggleLogWindow('/var/tmp/vim-messages.txt')<cr>
" close auxiliary buffers
nnoremap <leader>ca :call <sid>CloseAuxiliaryBuffers()<cr>

" Tags
nnoremap <space>[ :Tags <c-r><c-w><cr>
nnoremap <space>] :Tags<cr>
nnoremap <space>e :<c-u>call <sid>MaybeSplit() <bar> silent YcmCompleter GoToDefinition<cr>

" Easier change and replace word
nnoremap c* *Ncgn
nnoremap c# #NcgN

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
" copy file name to clipboard
nnoremap <leader>cf :let @* = fnameescape(expand("%:t"))<cr>
" copy relative path to clipboard
nnoremap <leader>cp :let @* = fnameescape(expand("%"))<cr>
" copy full path (with ~) to clipboard
nnoremap <leader>cP :let @* = fnameescape(expand("%:~"))<cr>
" copy full path, line and column number
nnoremap <leader>cr :call <sid>CopyCursorReference()<cr>
" go to file path (like vim's gf mapping), but also line and column number
nnoremap <leader>gf :<c-u>call <sid>GoToCursorReference()<cr>
" open file in system view (e.g., pdf, image, csv)
nnoremap <leader>oS :SysOpen<cr>
" open folder of current file in Finder
nnoremap <leader>oF :OpenFolderInFinder<cr>

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
nnoremap <leader>rr :Qargs <Bar> argdo %s/<c-r>=GetSubstituteTerm2()<cr>//g <Bar> update<c-f>F/<c-c>
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

" Paste from clipboard in insert and command-line mode
inoremap <c-q> <c-r>*
cnoremap <c-q> <c-r>*

" Insert the current filename with <c-g>f
" (and the built-in <c-r>% is used to insert the current relative path)
inoremap <c-g>f <c-r>=expand('%:t')<cr>
cnoremap <c-g>f <c-r>=expand('%:t')<cr>

" Paste escaped content from clipboard in command-line (search) mode.
" Useful when pasting a path for search.
" Based on s:VisualStar
cnoremap <c-g>e \V<c-r>=substitute(escape(getreg('*'), '/\'), '\n', '\\n', 'g')<cr>

nnoremap <space>r :w<cr>:call RefreshChrome()<cr>

imap <c-x><c-x> <plug>(fzf-complete-line)

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" Go align Elixir paragraph
nmap gae gaipe

" }}}

" Plugin settings ---------------------- {{{

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ackprg = 'ag --vimgrep'
  let g:ackhighlight = 1
endif

if !executable('hs')
  let g:auto_change_keyboard_layout = 0
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
" don't fill new Golang files with template content
let g:go_template_autocreate = 0
" use popup for :GoDoc
let g:go_doc_popup_window = 1
" don't add K as :GoDoc mapping.
" K is mapped to s:GoDocToggle instead
let g:go_doc_keywordprg_enabled = 0
" disable snippets shipped with the plugin
let g:go_snippet_engine = ''

" Colorizer
" keep buffer colorized when you leave it
let g:colorizer_disable_bufleave = 1

" }}}

" vimrc override ---------------------- {{{

if exists('$DOTFILES_PRIVATE') && filereadable($DOTFILES_PRIVATE . '/vimrc.local')
  execute 'source ' . $DOTFILES_PRIVATE . '/vimrc.local'
endif

" }}}
