"# vim: set foldmethod=marker:

" Plugins ---------------------- {{{
set rtp+=/usr/local/opt/fzf
set rtp+=$HOME/work/dotfiles-private/vim

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
  if get(g:, 'statusline_show_ext_info', 0) && &ft == 'vim' && &rtp =~ 'scriptease'
    let script_id = scriptease#scriptid('%')
    if empty(script_id)
      " e.g. script in autoload folder was not loaded yet
      let script_id = '?'
    endif
    let str .= printf(' | <SNR>%s', script_id)
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
  let isActiveWindow = get(a:, 1, 1)
  let showFlags = (index(['qf', 'help'], &filetype) == -1) && !get(b:, 'statusline_skip_flags')
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
endif

try
  " base16-vim plugin config:
  " Access colors present in 256 colorspace
  " https://github.com/chriskempson/base16-vim#256-colorspace
  let base16colorspace=256
  colorscheme base16-default-dark
catch /^Vim\%((\a\+)\)\=:E185/
  " Don't fail if base16-vim plugin is not installed
endtry

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

augroup AutoSaveFolds
  " Whitelist of filetypes that will have folding saved/restored.
  " When using :edit in these filetypes, folds will not be reset.
  "
  " Using a whitelist because there will be exceptions like
  " quickfix, netrw and help buffers. And also special buffers
  " used by plugins like plug, fzf, fugitive, etc.
  let ft_save_fold = ['typescript']
  autocmd!
  " Mkview
  "
  " Note: BufUnload requires <afile>
  " https://vi.stackexchange.com/a/22341
  "
  autocmd BufUnload * let ft = getbufvar(expand('<afile>'), '&ft') | if index(ft_save_fold, ft) >= 0 | mkview | endif
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
  call writefile([], "/var/tmp/vim-messages.txt")
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
" - yank result
"
" Example:
" :Log
" :Log 2 + 2
" :Log range(1, 5)
" :Log b:
command! -complete=expression -nargs=? Log
      \ try |
      \   if !empty(<q-args>) |
      \     call <sid>LogExprResult(eval(<q-args>)) |
      \   elseif !empty(expand('<sfile>')) |
      \     call <sid>LogSourcedFile(expand('<sfile>'), expand('<slnum>')) |
      \   endif |
      \ catch |
      \   let msg = matchstr(v:exception, 'Vim.*:\zsE\d\+: .*') |
      \   call <sid>LogLines([msg], 1) |
      \ endtry

function! s:LogExprResult(result) abort
  let lines = split(scriptease#dump(a:result, {'width': &columns - 1}), "\n")
  call s:LogLines(lines)
endfunction

function! s:LogSourcedFile(sfile, slnum) abort
  let line = a:sfile . ', line ' . a:slnum
  call s:LogLines([line])
endfunction

function! s:LogLines(lines, ...) abort
  let is_error = get(a:, 1, 0)
  for line in a:lines
    if is_error
      echohl ErrorMsg
      echomsg line
      echohl NONE
    else
      echomsg line
    endif
  endfor
  let @* = a:lines[-1]
  let a:lines[0] = printf('[%s] %s', strftime('%H:%M:%S'), a:lines[0])
  call writefile(a:lines, "/var/tmp/vim-messages.txt", "a")
  call s:RefreshBuffer("/var/tmp/vim-messages.txt")
endfunction

function! s:RefreshBuffer(path) abort
  try
    execute 'silent checktime ' . a:path
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
  let cmd = 'mv ' . path . '* ' . @% . ' && rmdir ' . path
  let output = system(cmd)
  if v:shell_error
    echohl Error
    echom 'DirvishImplode: Error: ' . output
    echohl NONE
  endif
  call s:DirvishRefresh()
endfunction

function! ArgList() abort
  let i = 0
  let l = []
  while i < argc()
    call add(l, argv(i))
    let i = i + 1
  endwhile
  return l
endfunction

function! s:DirvishMv() abort
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
  let cmd = 'mv ' . join(map(filepaths, 'fnameescape(v:val)'), ' ') . ' ' . fnameescape(dirpath)
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

function! s:ToggleGlobalVar(varname) abort
  let value = get(g:, a:varname, 0)
  if value == 0
    let g:[a:varname] = 1
  else
    let g:[a:varname] = 0
  endif
endfunction

function! s:ShouldColorColumn()
  if get(b:, 'skip_color_column')
    return 0
  endif
  return index(['qf', 'diff', 'undotree', 'agit', 'agit_stat', 'agit_diff', 'rc_git_log', 'rc_git_branches', 'rc_git_diff', 'fugitive', 'fugitiveblame'], &filetype) == -1
endfunction

function! s:ShouldCursorLine()
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

function! s:CdToGitRoot(cd_cmd)
  let output = util#GetGitRoot()
  if empty(output)
    return util#error_msg("CdToGitRoot: couldn't find git root")
  endif
  let cmd = a:cd_cmd . ' ' . output
  execute cmd
  echo cmd
endfunction

function! s:CdToNodeJsRoot(cd_cmd) abort
  let package_json_path = findfile('package.json', '.;' . util#GetGitRoot())
  if empty(package_json_path)
    return util#error_msg("CdToNodeJsRoot: couldn't find package.json")
  endif
  " Expand to full path (:~) for better logs,
  " then get the directory (:h).
  let nodejs_root = fnamemodify(package_json_path, ':~:h')
  let cmd = a:cd_cmd . ' ' . nodejs_root
  execute cmd
  echo cmd
endfunction

function! s:CdToBufferDir(cd_cmd) abort
  " Expand to full path (:~) for better logs,
  " then get the directory (:h).
  let path = expand('%:~:h')
  if empty(path)
    return util#error_msg("CdToBufferDir: buffer doesn't have a disk path")
  endif
  let cmd = a:cd_cmd . ' ' . path
  execute cmd
  echo cmd
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

function! s:EditSketchBuffer(ft)
  if a:ft ==# 'typescript'
    call util#EditFile('~/work/dotfiles-private/src/sketch.ts')
    nnoremap <buffer> <space>t :update <bar> Dispatch! ts-node --project ~/work/dotfiles-private/tsconfig.json % <bar>& tee /var/tmp/test-results.txt /var/tmp/test-console.txt<cr>
  elseif a:ft ==# 'javascript'
    call util#EditFile('~/work/dotfiles-private/src/sketch.js')
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
  execute 'Ag --hidden -Q "' . a:input . '" -G "\.txt$" ' . s:GetNoteDirs()
endfunction
command! -nargs=* SearchNotes call s:SearchNotes(<q-args>)

function! s:FzfNotes() abort
  let cmd = 'find ' . s:GetNoteDirs() . ' -type f -name "*.txt"'
  call fzf#run(fzf#wrap({'source': cmd}))
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
  execute 'Ag --hidden -Q "' . a:input . '" ' . s:GetDotfilesDirs()
endfunction
command! -nargs=* SearchDotfiles :call <sid>SearchDotfiles(<q-args>)

function! s:FzfDotfiles() abort
  let cmd = 'ag -g "" --hidden ' . s:GetDotfilesDirs()
  call fzf#run(fzf#wrap({'source': cmd}))
endfunction

function! s:GetDotfilesDirs() abort
  let dirs = ['~/work/dotfiles/', '~/work/dotfiles-private/']
  if exists('$DOTFILES_WORK') && isdirectory($DOTFILES_WORK)
    call add(dirs, fnameescape($DOTFILES_WORK))
  endif
  return join(dirs, ' ')
endfunction

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
  elseif &ft == 'javascript'
    let parser='babel'
  elseif index(['typescript', 'typescript.jsx'], &ft) >= 0
    let parser='typescript'
  elseif &ft == 'markdown'
    let parser='markdown'
  elseif &ft == 'html'
    let parser='html'
  endif
  if empty(parser)
    return util#error_msg('Unsupported filetype: ' . &ft)
  endif
  let save_pos = getpos('.')
  let opts = ''
  " Try to find .prettierrc.json upwards until the git root.
  " This would be an evidence that the project uses prettier.
  let prettierrc_json = findfile('.prettierrc.json', '.;' . util#GetGitRoot())
  if empty(prettierrc_json)
    " Use global prettier config for example in sketch buffers or
    " projects that don't have prettier installed.
    let opts = "--config=" . $HOME . "/work/dotfiles-private/.prettierrc "
  endif
  execute "%!npx prettier " . opts . "--parser=" . parser
  call setpos('.', save_pos)
  silent! write
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

function! s:CopyCursorReference() abort
  let path = expand("%:~")
  let line_num = line('.')
  let col_num = col('.')
  let @* = printf('%s:%s:%s', path, line_num, col_num)
endfunction

function! s:GoToCursorReference() abort
  let should_split = v:count > 0
  let line = getline('.')
  let cursor = getpos('.')
  try
    if should_split
      vsplit
    endif
    normal! gf
  catch /E447/
    if should_split
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

" Open/close window, depending on whether the file is opened in the current tab.
function! s:ToggleWindowInTab(path, ...)
  let wincmd = get(a:, 1, 'vsplit')
  let opencmd = "silent " . wincmd . " " . a:path
  if bufnr(a:path) == -1
    " If no buffer (across all tabs), open file
    " (new buffer and window)
    execute opencmd
    return 1
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      " If buffer exists, but no corresponding window (across all tabs), open file
      execute opencmd
      return 1
    else
      for win in wins
        if getwininfo(win)[0]['tabnr'] == tabpagenr()
          " If already opened in tab, close file
          call win_gotoid(win)
          wincmd c
          return 0
        endif
      endfor
      " If not already opened in tab, open file
      execute opencmd
      return 1
    endif
  endif
endfunction

function! s:CloseWindowInTab(path)
  if bufnr(a:path) == -1
    return 0
  else
    let wins = getbufinfo(a:path)[0]['windows']
    if empty(wins)
      return 0
    else
      for win in wins
        if getwininfo(win)[0]['tabnr'] == tabpagenr()
          call win_gotoid(win)
          wincmd c
          return 1
        endif
      endfor
      return 0
    endif
  endif
endfunction

" Open/close a log window on the right side of the current tab
" and keep all other log windows closed.
function! s:ToggleLogWindow(target_path)
  let paths = [
        \'/var/tmp/test-console.txt',
        \'/var/tmp/test-results.txt',
        \'/var/tmp/vim-messages.txt'
        \]
  let oldwinnr = winnr()
  let opened = s:ToggleWindowInTab(a:target_path)
  if opened == 1
    " Window was opened.
    " Keep window on the right side.
    wincmd L
    setlocal wrap
    setlocal foldlevel=20
    " Close all the other log windows.
    for path in paths
      if path != a:target_path
        call s:CloseWindowInTab(path)
      endif
    endfor
  endif
  " Go back to original window
  if winbufnr(oldwinnr) != -1
    execute oldwinnr . "wincmd w"
  endif
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
" Toggle showing extended info in statusline
nnoremap <silent> cos :call <sid>ToggleGlobalVar('statusline_show_ext_info')<cr>

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
nnoremap <leader>ev :call util#EditFile($MYVIMRC)<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" yank last message
nnoremap <leader>ym :Ym<cr>
" :Log {expr}
nnoremap <space>v :Log<space>
" reload syntax highlighting
nnoremap <leader>sy :syntax sync fromstart<cr>

" Browse files & search
" quickly edit some files and folders
nnoremap <leader>el :call util#EditFile('~/.vim/vimrc.local')<cr>
nnoremap <leader>ess :UltiSnipsEdit<cr>
nnoremap <leader>esp :e ~/work/dotfiles-private/vim/UltiSnips/<c-r>=&filetype<cr>.snippets<cr>
nnoremap <leader>eag :e ./.ignore<cr>
nnoremap <leader>eo :call util#EditFileUpwards(".todo")<cr>
nnoremap <leader>en :call <sid>FzfNotes()<cr>
nnoremap <leader>ei :call util#EditFile("~/Dropbox/notes/dev/dev.txt")<cr>
nnoremap <leader>em :call util#EditFile("~/work/dotfiles-private/README.md")<cr>
nnoremap <leader>eb :call util#EditFile("~/.bashrc.local")<cr>
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
" grep operator
nnoremap <space>g :set operatorfunc=<sid>GrepOperator<cr>g@
vnoremap <space>g :<c-u>call <sid>GrepOperator(visualmode())<cr>
nnoremap <space>G :set operatorfunc=<sid>GrepOperatorInGitRoot<cr>g@
vnoremap <space>G :<c-u>call <sid>GrepOperatorInGitRoot(visualmode())<cr>
" search in file (from visual mode)
xnoremap * :<c-u>call <sid>VisualStar('/')<cr>/<c-r>=@/<cr><cr>
xnoremap # :<c-u>call <sid>VisualStar('?')<cr>?<c-r>=@/<cr><cr>
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

" Tags
nnoremap <space>[ :Tags <c-r><c-w><cr>
nnoremap <space>] :Tags<cr>
nnoremap <space>e :silent YcmCompleter GoToDefinition<cr>
nnoremap <leader>js :split <bar> silent YcmCompleter GoToDefinition<cr>
nnoremap <leader>jv :vsplit <bar> silent YcmCompleter GoToDefinition<cr>

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
nnoremap <leader>cf :let @* = expand("%:t")<cr>
" copy relative path to clipboard
nnoremap <leader>cp :let @* = expand("%")<cr>
" copy full path (with ~) to clipboard
nnoremap <leader>cP :let @* = expand("%:~")<cr>
" copy full path, line and column number
nnoremap <leader>cr :call <sid>CopyCursorReference()<cr>
" go to file path (like vim's gf mapping), but also line and column number
nnoremap <leader>gf :<c-u>call <sid>GoToCursorReference()<cr>
" open file in system view (e.g., pdf, image, csv)
nnoremap <leader>oS :SysOpen<cr>

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

let vimrc_local = $HOME . '/.vim/vimrc.local'
if filereadable(vimrc_local)
  execute 'source ' . vimrc_local
endif

" }}}
