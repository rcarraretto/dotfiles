augroup AutoCd
  autocmd!
  autocmd BufRead,BufNewFile ~/work/dotfiles* call cwd#AutoCd()
augroup END

function! s:ProjectSpecificSetup() abort
  if !exists('g:project_configs')
    return
  endif
  let path = expand('%:~')
  for config in g:project_configs
    if stridx(path, config['cwd']) == 0
      call function(config['setup_func'])(config)
      return
    endif
  endfor
endfunction

augroup ProjectSpecificConfigs
  " https://stackoverflow.com/a/48425153
  " BufRead,BufNewFiles are not triggered on dirvish buffers,
  " so we need to set an additional FileType autocmd.
  autocmd!
  autocmd FileType dirvish call s:ProjectSpecificSetup()
  autocmd BufRead,BufNewFile * call s:ProjectSpecificSetup()
augroup END
