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

# Base 16
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Ctrl+S in vim
stty -ixon -ixoff

# Go language
export GOPATH=~/tmp/.go
export PATH=$PATH:$GOPATH/bin

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

LOCAL_RC=$HOME/.bashrc.local
test -f $LOCAL_RC && source $LOCAL_RC
