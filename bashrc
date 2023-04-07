if [ -z "$PS1" ]; then
  # if shell is non-interactive (e.g., when doing scp), bail
  return
fi

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
  profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  if [ -n "$profile" ]; then
    PS1+="[$profile] "
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
export DOTFILES_HOME_FIXTURES="$HOME/work/dotfiles-home-fixtures"
export DOTFILES_WORK="$HOME/work/dotfiles-work"
if [ -z "$DOTFILES_DIRS" ]; then
  export DOTFILES_DIRS="$DOTFILES_PUBLIC"
  [ -d "$DOTFILES_PRIVATE" ] && DOTFILES_DIRS="$DOTFILES_DIRS:$DOTFILES_PRIVATE"
  [ -d "$DOTFILES_HOME" ] && DOTFILES_DIRS="$DOTFILES_DIRS:$DOTFILES_HOME"
  [ -d "$DOTFILES_HOME_FIXTURES" ] && DOTFILES_DIRS="$DOTFILES_DIRS:$DOTFILES_HOME_FIXTURES"
  [ -d "$DOTFILES_WORK" ] && DOTFILES_DIRS="$DOTFILES_DIRS:$DOTFILES_WORK"
fi

# Ctrl+S in vim
stty -ixon -ixoff

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

if ! command-exists brew; then
  # Mac M1 brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# brew prefix changed in Mac M1, so can't hard-code paths to /usr/local anymore
export BREW_PREFIX=$(brew --prefix)

# Dotfiles bin
add-to-path "$HOME/work/dotfiles/bin"
add-to-path "$HOME/work/dotfiles/node/bin"

# if brew 'findutils' is installed, add it to $PATH
# so 'xargs' and 'man xargs' point to 'gxargs'
if command-exists gxargs; then
  add-to-path "$BREW_PREFIX/opt/findutils/libexec/gnubin"
fi

# ruby
add-to-path "$HOME/.rbenv/shims"

# this function prevents variables from leaking to all shells
# https://stackoverflow.com/q/27777826/2277505
__private_scope() {
  # Base 16
  local base16_shell="$HOME/.config/base16-shell"
  [ -s "$base16_shell/profile_helper.sh" ] && eval "$($base16_shell/profile_helper.sh)"

  # Node.js
  if [ -f "$DOTFILES_WORK/.nvmrc" ]; then
    local node_version=$(head -n 1 "$DOTFILES_WORK/.nvmrc")
  elif [ -f "$DOTFILES_PRIVATE/.nvmrc" ]; then
    local node_version=$(head -n 1 "$DOTFILES_PRIVATE/.nvmrc")
  fi
  if [ -n "$node_version" ]; then
    add-to-path "$HOME/.nvm/versions/node/$node_version/bin"
  fi

  # Python binaries (like AWS CLI)
  if [ -f "$BREW_PREFIX/bin/python3" ] \
    && ! path-contains "$HOME/Library/Python/[0-9.]+/bin"; then
    local python_user_base=$(python3 -m site --user-base)
    add-to-path "$python_user_base/bin" after
  fi
}
__private_scope

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
  if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
    source "$BREW_PREFIX/etc/bash_completion"
  fi
}

# `cd` with fzf on ~/work
cw() {
  local dirs=$(find "$HOME/work" -mindepth 1 -maxdepth 1 -type d)
  if [ $# -eq 0 ]; then
    local dir=$(echo "$dirs" | fzf)
  else
    local dir=$(echo "$dirs" | ag "$1" | head -n 1)
  fi
  if [ -z "$dir" ]; then
    return 1
  fi
  cd "$dir" && pwd
}

# <c-x>y: Copy current line to clipboard
copyline() {
  printf %s "$READLINE_LINE" | pbcopy
}
bind -x '"\C-xy":copyline'

# <c-x>c: Fzf personal bins and functions
source "$DOTFILES_PUBLIC/bash/fzf-script-functions.sh"
bind -x '"\C-xc":_fzf_script_functions'

source ~/.bash_aliases

source "$DOTFILES_PUBLIC/bash/tmux-startup.sh"

if [ -f "$DOTFILES_PRIVATE/bashrc.private" ]; then
  source "$DOTFILES_PRIVATE/bashrc.private"
fi
if [ -f "$DOTFILES_HOME/bashrc.home" ]; then
  source "$DOTFILES_HOME/bashrc.home"
elif [ -f "$DOTFILES_WORK/bashrc.work" ]; then
  source "$DOTFILES_WORK/bashrc.work"
fi

__tmux_startup
