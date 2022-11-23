augroup JavascriptConfig
  autocmd!
  autocmd FileType javascript,typescript,typescript.tsx call proglang#javascript#Config()
  " Auto reload typescript files on save (tsuquyomi plugin)
  autocmd BufWritePost *.ts,*.tsx call proglang#javascript#TypescriptReload()
augroup END
