#!/usr/bin/env bash

# The aliases below can be used in vim (:!{cmd}, e.g., !python),
# because of this line in vimrc:
# let $BASH_ENV = "~/.bash_aliases"
# https://stackoverflow.com/a/18901595

shopt -s expand_aliases

alias sb='source ~/.bashrc'

# ls
# -G: color
# -F: append '/' to directories, '*' to executables, etc.
alias ls='ls -GF'
# -A: show everything, but don't show '.' and '..'
# -1: only show file names
alias ll='ls -GFA1'
