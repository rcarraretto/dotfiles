PROMPT_COMMAND=__prompt_command

__prompt_command() {
  local EXIT_CODE="$?"
  local RED='\[\e[0;31m\]'
  local NC='\[\e[0m\]'
  PS1=""
  if { [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 130 ]; }; then
    # Show the exit code on prompt,
    # except when exit code is 130 (set when Ctrl-C)
    # https://tldp.org/LDP/abs/html/exitcodes.html
    PS1+="${RED}${EXIT_CODE}${NC} "
  fi
  PS1+='\W $ '
  # After each command, refresh tmux status bar,
  # since the current git branch is being displayed on it.
  tmux refresh-client -S &> /dev/null
}

# Vim
export EDITOR='vim'

# - Sets Bash 4 language to English
# - Sets :language on vim (fixes "echo 2.0 * 2")
# - Makes emoji work properly inside tmux
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# history size
export HISTFILESIZE=1000
export HISTSIZE=1000

export DOTFILES_PUBLIC="$HOME/work/dotfiles"
export DOTFILES_PRIVATE="$HOME/work/dotfiles-private"
export DOTFILES_HOME="$HOME/work/dotfiles-home"
export DOTFILES_WORK="$HOME/work/dotfiles-work"

alias sb='source ~/.bashrc'

# ls
# -G: color
# -F: append '/' to directories, '*' to executables, etc.
alias ls='ls -GF'
# -A: show everything, but don't show '.' and '..'
# -1: only show file names
alias ll='ls -GFA1'

source ~/.bash_aliases

# Prevent re-adding the same path to $PATH,
# when sourcing the bashrc multiple times.
#
# https://unix.stackexchange.com/a/217629
#
# To check if everything works, one could count the entries in $PATH,
# before and after re-sourcing the bashrc:
# echo "$PATH" | tr : \\n | wc -l
#
path-contains() {
  echo "$PATH" | grep -Eq "(^|:)$1($|:)"
}
add-to-path() {
  if path-contains "$1"; then
    return
  fi
  if [ "$2" = "after" ]; then
    PATH="$PATH:$1"
  else
    PATH="$1:$PATH"
  fi
}

print-path() {
  echo "$PATH" | tr : \\n
}

command-exists() {
  command -v "$1" 1>/dev/null 2>&1
}

# Dotfiles bin
add-to-path "$HOME/work/dotfiles/bin"

# Base 16
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Ctrl+S in vim
stty -ixon -ixoff

# Nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ] && ! command-exists nvm; then
  source "$NVM_DIR/nvm.sh" # && echo "nvm set!"
fi

# rbenv
if command-exists rbenv && [ -z $RBENV_SET ]; then
  eval "$(rbenv init -)" && RBENV_SET=1 # && echo "rbenv set!"
fi

# fzf
export FZF_DEFAULT_COMMAND='ag -g "" --hidden'
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# git completion
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# bash-completion
# used by docker completion
load-completion() {
  BREW_PREFIX=$(brew --prefix)
  if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
    source "$BREW_PREFIX/etc/bash_completion"
  fi
}

LOCAL_RC="$DOTFILES_PRIVATE/bashrc.private"
test -f $LOCAL_RC && source $LOCAL_RC
