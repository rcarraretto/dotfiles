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
nnoremap <leader>ess :<c-u>call window#MaybeSplit() <bar> UltiSnipsEdit<cr>
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
nnoremap <space>e :<c-u>call window#MaybeSplit() <bar> YcmCompleter GoToDefinition<cr>
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
" Change between different styles of quotes
nnoremap <leader>' :call editing#ChangeQuotes()<cr>
nnoremap <leader>iv :call proglang#InsertVariable()<cr>

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

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" Go align Elixir paragraph
nmap gae gaipe

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

augroup OverrideMappings
  autocmd!
  " Reset <cr> in cmdline window to execute the command,
  " because <cr> is remapped in normal mode to :
  autocmd CmdwinEnter * nnoremap <buffer> <cr> <cr>
  " On quickfix, make 'o' open the target line,
  " because <cr> is remapped in normal mode to :
  autocmd BufReadPost quickfix nnoremap <buffer> o <cr>
  autocmd VimEnter * call s:OverridePluginMappings()
  autocmd FileType vim call mapping#VimscriptMappings()
  autocmd FileType go call mapping#GolangMappings()
  autocmd FileType agit call mapping#AgitMappings()
  autocmd BufEnter * call mapping#FugitiveMappings()
  autocmd FileType javascript,typescript,typescript.tsx call mapping#JavascriptMappings()
  autocmd FileType typescript,typescript.tsx call mapping#TypescriptMappings()
augroup END