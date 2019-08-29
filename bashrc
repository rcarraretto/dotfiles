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
  if ! path-contains "$1"; then
    if [ "$2" = "after" ] ; then
      PATH="$PATH:$1"
    else
      PATH="$1:$PATH"
    fi
  fi
}

# Dotfiles bin
add-to-path "$HOME/work/dotfiles/bin"

# Base 16
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Ctrl+S in vim
stty -ixon -ixoff

# Python bins from 'pip install --user'
add-to-path ~/Library/Python/2.7/bin after

# Ruby env
if command -v rbenv 1>/dev/null 2>&1; then
  ! path-contains "$HOME/.rbenv/shims" && eval "$(rbenv init -)"
fi
# Python env
if command -v pyenv 1>/dev/null 2>&1; then
  ! path-contains "$HOME/.pyenv/shims" && eval "$(pyenv init -)"
fi

# Nvm
export NVM_DIR="$HOME/.nvm"
[[ -z "$NVM_BIN" ]] && [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# fzf
export FZF_DEFAULT_COMMAND='ag -g "" --hidden'
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# git completion
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# After each command, refresh tmux status bar,
# since the current git branch is being displayed on it.
if ! [[ "$PROMPT_COMMAND" =~ "tmux refresh-client" ]]; then
  PROMPT_COMMAND="tmux refresh-client -S &> /dev/null; $PROMPT_COMMAND"
fi

LOCAL_RC=$HOME/.bashrc.local
test -f $LOCAL_RC && source $LOCAL_RC
