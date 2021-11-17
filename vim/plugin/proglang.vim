command! Prettier call proglang#Prettier('')
command! -nargs=1 EditSketchBuffer call proglang#EditSketchBuffer(<q-args>)

augroup ProglangConfig
  autocmd!
  autocmd FileType go call proglang#GolangConfig()
augroup END
