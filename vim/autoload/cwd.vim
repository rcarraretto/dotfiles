function! cwd#AutoCd() abort
  let git_root = util#GetGitRoot({'full_path': 1})
  if git_root == $HOME . '/work/dotfiles/vim/bundle/YouCompleteMe/third_party/ycmd'
    " Do not :cd to ycm when jumping to NodeJS standard lib
    return
  endif
  if empty(git_root)
    return
  endif
  let dotfiles = [
        \ $DOTFILES_PUBLIC,
        \ $DOTFILES_PRIVATE,
        \ $DOTFILES_HOME,
        \ $DOTFILES_WORK
        \ ]
  if index(dotfiles, git_root) >= 0 && get(g:, 'AUTO_CD_DOTFILES', 1) == 0
    " Log printf('AutoCd: skip dotfiles: %s', expand('%:p'))
    return
  endif
  " Log printf("AutoCd: lcd to %s (from %s) / file: %s", git_root, getcwd(), expand('%:p'))
  execute "lcd " . git_root
endfunction

function! s:Cd(cd_cmd, cd_dir) abort
  let cmd = a:cd_cmd . ' ' . a:cd_dir
  execute cmd
  echo cmd
endfunction

function! cwd#CdToGitRoot(cd_cmd)
  let path = util#GetGitRoot()
  if empty(path)
    return util#error_msg("CdToGitRoot: couldn't find git root")
  endif
  call s:Cd(a:cd_cmd, path)
endfunction

function! cwd#CdToNodeJsRoot(cd_cmd) abort
  let path = util#GetNodeJsRoot()
  if empty(path)
    return util#error_msg("CdToNodeJsRoot: couldn't find package.json")
  endif
  call s:Cd(a:cd_cmd, path)
endfunction

function! cwd#CdToBufferDir(cd_cmd) abort
  " Expand to full path (:~) for better logs,
  " then get the directory (:h).
  let path = expand('%:~:h')
  if empty(path)
    return util#error_msg("CdToBufferDir: buffer doesn't have a disk path")
  endif
  call s:Cd(a:cd_cmd, path)
endfunction
