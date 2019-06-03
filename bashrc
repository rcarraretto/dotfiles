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

# Dotfiles bin
export PATH="$HOME/work/dotfiles/bin:$PATH"

# Base 16
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Ctrl+S in vim
stty -ixon -ixoff

# Python bins from 'pip install --user'
export PATH=$PATH:~/Library/Python/2.7/bin

# Ruby env
if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi
# Python env
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"

export FZF_DEFAULT_COMMAND='ag -g "" --hidden'

# git completion
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

# After each command, refresh tmux status bar,
# since the current git branch is being displayed on it.
PROMPT_COMMAND="tmux refresh-client -S &> /dev/null; $PROMPT_COMMAND"

LOCAL_RC=$HOME/.bashrc.local
test -f $LOCAL_RC && source $LOCAL_RC
