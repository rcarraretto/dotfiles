shopt -s expand_aliases

# Maya
alias maya='docker run -it --rm -v $(pwd):/usr/src/plugin-repo -v $HOME/programming/wizehive-dev/maya:/usr/src/app --name maya-running maya'
