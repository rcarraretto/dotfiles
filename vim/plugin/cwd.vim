augroup AutoCd
  autocmd!
  autocmd BufRead,BufNewFile ~/work/dotfiles/vim/bundle/*,$DOTFILES_PUBLIC/*,$DOTFILES_PRIVATE/*,$DOTFILES_HOME/*,$DOTFILES_WORK/* call cwd#AutoCd()
augroup END
