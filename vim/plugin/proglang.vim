command! Prettier call proglang#Prettier('')
command! -nargs=1 EditSketchBuffer call proglang#EditSketchBuffer(<q-args>)
command! -nargs=* DispatchAndCapture call proglang#DispatchAndCapture(<q-args>)
