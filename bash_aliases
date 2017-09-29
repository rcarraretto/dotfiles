shopt -s expand_aliases

# Maya
alias maya='docker run -it --rm -v $(pwd):/usr/src/plugin-repo -v $HOME/work/maya:/usr/src/app --name maya-running maya'

alias st='open -a SourceTree .'
