#!/usr/bin/env bash

# The aliases below can be used in vim (:!{cmd}, e.g., !python),
# because of this line in vimrc:
# let $BASH_ENV = "~/.bash_aliases"
# https://stackoverflow.com/a/18901595

shopt -s expand_aliases

# Make 'python' refer to 'python3' (from homebrew)
if [ -f "$BREW_PREFIX/bin/python3" ]; then
  alias python="$BREW_PREFIX/bin/python3"
fi
# Make 'pip' refer to 'pip3' (from python homebrew)
if [ -f "$BREW_PREFIX/bin/pip3" ]; then
  alias pip="$BREW_PREFIX/bin/pip3"
fi
