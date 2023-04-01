function! cwd#AutoCd() abort
  " Do not resolve symlinks because a .todo file is a symlink to a $NOTES dir
  " and we do not want to cd to $NOTES but to $DOTFILES.
  let git_root = util#GetGitRoot({
        \'full_path': 1,
        \'resolve_symlink': 0,
        \})
  if git_root == $HOME . '/work/dotfiles/vim/bundle/YouCompleteMe/third_party/ycmd'
    " Do not :cd to ycm when jumping to NodeJS standard lib
    return
  endif
  if empty(git_root)
    return
  endif
  if stridx(getcwd(), git_root) != -1
    " If cwd is already correct, no need to set it.
    " If cwd is a subdirectory, do not reset it to git root.
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

function! cwd#CdToProgLangRoot(cd_cmd) abort
  if &ft == 'go'
    let filename = 'go.mod'
  else
    let filename = 'package.json'
  endif
  let path = cwd#FindFileUpwards(filename)
  if empty(path)
    return util#error_msg("CdToProgLangRoot: couldn't find file: " . filename)
  endif
  call s:Cd(a:cd_cmd, path)
endfunction

function! cwd#FindFileUpwards(filename) abort
  let path = findfile(a:filename, '.;' . $HOME . '/work')
  if empty(path)
    return 0
  endif
  " Expand to full path (:~) for better logs,
  " then get the directory (:h).
  return fnamemodify(path, ':~:h')
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

function! cwd#ToggleCwd(cd_cmd) abort
  let buf_dir = fnamemodify(getcwd(), ':~')
  let matched_projects = filter(keys(g:toggle_cwd_dirs), 'stridx(buf_dir, v:val) == 0')
  if empty(matched_projects)
    return util#error_msg('ToggleCwd: cwd is not a known project: ' . buf_dir)
  endif
  let project = matched_projects[0]
  let rel_path = strpart(buf_dir, len(project) + 1)
  let rel_paths = g:toggle_cwd_dirs[project]
  let matched_paths = filter(copy(rel_paths), 'stridx(rel_path, v:val) == 0')
  if empty(matched_paths)
    " e.g. when on git root, switch to first relative path
    let next_rel_path = rel_paths[0]
  else
    if len(rel_paths) == 1
      try
        " if rel_paths is e.g. ['some/path'],
        " toggle between 'some/path' and whatever was the previous path
        execute a:cd_cmd . ' -'
        echom a:cd_cmd . ' ' . getcwd()
        return
      catch /E186/
        return util#error_msg('ToggleCwd: no previous directory')
      endtry
    endif
    let idx = index(rel_paths, matched_paths[0])
    " PPmsg [rel_path, rel_paths, matched_paths[0], idx]
    if idx + 1 < len(rel_paths)
      let next_rel_path = rel_paths[idx + 1]
    else
      let next_rel_path = rel_paths[0]
    endif
  endif
  let next_path = project . '/' . next_rel_path
  execute a:cd_cmd . ' ' . next_path
  echom a:cd_cmd . ' ' . getcwd()
endfunction
