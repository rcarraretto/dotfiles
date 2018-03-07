# Vim
export EDITOR='vim'

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

# Python and Ruby envs
if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
# eval "$(docker-machine env default)"

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"
