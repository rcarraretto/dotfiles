# Vim
export EDITOR='vim'

source ~/.bash_aliases

# Base 16
BASE16_SHELL=~/programming/dotfiles/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# Ctrl+S in vim
stty -ixon -ixoff

# PHP
export PATH=/usr/local/php5/bin:$PATH

# Go language
export GOPATH=~/tmp/.go
export PATH=$PATH:$GOPATH/bin

# Python bins from 'pip install --user'
export PATH=$PATH:~/Library/Python/2.7/bin

# Python and Ruby envs
eval "$(rbenv init -)"
eval "$(pyenv init -)"
# eval "$(docker-machine env default)"

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"

# Zengine devenv
export PRIVATE_IP="10.0.18.12"
