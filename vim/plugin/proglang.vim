command! Prettier call proglang#Prettier('')
command! -nargs=1 EditSketchBuffer call proglang#EditSketchBuffer(<q-args>)
command! -nargs=* DispatchAndCapture call proglang#DispatchAndCapture(<q-args>)

augroup ProglangConfig
  autocmd!
  autocmd FileType javascript,typescript,typescript.tsx call proglang#JavascriptConfig()
  autocmd FileType go call proglang#GolangConfig()
  " Auto reload typescript files on save (tsuquyomi plugin)
  autocmd BufWritePost *.ts,*.tsx call proglang#TypescriptReload()
augroup END
