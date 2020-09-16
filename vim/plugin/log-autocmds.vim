" Adapted from:
" https://github.com/lervag/dotvim/blob/04bea4c50c0d47a2fc3301448e99e6eb145ae450/personal/plugin/log-autocmds.vim
" https://vi.stackexchange.com/a/4496

let s:should_log = 0

command! ToggleLogAutocmds call s:ToggleLogAutocmds()

function! s:LogAutoCmd(autocmd_name, file) abort
  let msg = a:autocmd_name . ' ' . a:file
  silent Log msg
endfunction

function! s:ToggleLogAutocmds() abort
  augroup LogAutocmds
    autocmd!
  augroup END

  let s:should_log = s:should_log ? 0 : 1
  if !s:should_log
    Log 'Stopped autocmd log'
    return
  endif

  Log 'Started autocmd log'
  augroup LogAutocmds
    for autocmd_name in s:autocmd_names
      execute 'autocmd' autocmd_name "* call s:LogAutoCmd('" . autocmd_name . "', expand('<afile>'))"
    endfor
  augroup END
endfunction

let s:autocmd_names = [
      \ 'BufAdd',
      \ 'BufCreate',
      \ 'BufEnter',
      \ 'BufFilePost',
      \ 'BufFilePre',
      \ 'BufLeave',
      \ 'BufNew',
      \ 'BufNewFile',
      \ 'BufRead',
      \ 'BufReadPost',
      \ 'BufReadPre',
      \ 'BufWinEnter',
      \ 'BufWinLeave',
      \ 'CmdUndefined',
      \ 'CmdwinEnter',
      \ 'CmdwinLeave',
      \ 'ColorScheme',
      \ 'FileReadPost',
      \ 'FileReadPre',
      \ 'FileType',
      \ 'FilterReadPost',
      \ 'FilterReadPre',
      \ 'QuickFixCmdPost',
      \ 'QuickFixCmdPre',
      \ 'QuitPre',
      \ 'RemoteReply',
      \ 'ShellCmdPost',
      \ 'ShellFilterPost',
      \ 'SourcePre',
      \ 'StdinReadPost',
      \ 'StdinReadPre',
      \ 'Syntax',
      \ 'TabEnter',
      \ 'TabLeave',
      \ 'TermResponse',
      \ 'User',
      \ 'VimEnter',
      \ 'VimLeave',
      \ 'VimLeavePre',
      \ 'WinEnter',
      \ 'WinLeave',
      \ ]

" Other autocmd_names:
" \ 'BufDelete',
" \ 'BufHidden',
" \ 'BufReadCmd'
" \ 'BufUnload',
" \ 'BufWipeout',
" \ 'BufWrite',
" \ 'BufWriteCmd'
" \ 'BufWritePost',
" \ 'BufWritePre',
" \ 'CompleteDone',
" \ 'CursorHold',
" \ 'CursorHoldI',
" \ 'CursorMoved',
" \ 'CursorMovedI',
" \ 'EncodingChanged',
" \ 'FileAppendCmd'
" \ 'FileAppendPost',
" \ 'FileAppendPre',
" \ 'FileChangedRO',
" \ 'FileChangedShell',
" \ 'FileChangedShellPost',
" \ 'FileReadCmd'
" \ 'FileWriteCmd'
" \ 'FileWritePost',
" \ 'FileWritePre',
" \ 'FilterWritePost',
" \ 'FilterWritePre',
" \ 'FocusGained',
" \ 'FocusLost',
" \ 'FuncUndefined'
" \ 'GUIEnter',
" \ 'GUIFailed',
" \ 'InsertChange',
" \ 'InsertCharPre',
" \ 'InsertEnter',
" \ 'InsertLeave',
" \ 'MenuPopup',
" \ 'SessionLoadPost',
" \ 'SourceCmd'
" \ 'SpellFileMissing',
" \ 'SwapExists',
" \ 'TermChanged',
" \ 'TextChanged',
" \ 'TextChangedI',
" \ 'VimResized',
