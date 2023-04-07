#!/usr/bin/env bash

_list_filenames_in_dir() {
  if [ $# -ne 1 ]; then
    echo "Error: _list_filenames_in_dir <dir>"
    return 1
  fi
  if ! [ -d "$1" ]; then
    return 1
  fi
  find "$1" -type f -not -path '*/\.*' -printf "%f\n"
}

_list_functions() {
  declare -F | sed 's/^declare -f[x]\{0,1\} //' \
    | grep -v '^_\|nvm\|node_version_has_solaris_binary\|\iojs_version_has_solaris_binary\|rbenv\|fzf-file-widget\|readlink';
}

_list_script_functions() {
  (\
    _list_functions; \
    _list_filenames_in_dir "$DOTFILES_PUBLIC/bin"; \
    _list_filenames_in_dir "$DOTFILES_PRIVATE/bin"; \
    _list_filenames_in_dir "$DOTFILES_HOME/bin"; \
    _list_filenames_in_dir "$DOTFILES_WORK/bin"; \
  ) | sort | uniq
}

# Based on fzf-file-widget
# https://github.com/junegunn/fzf/blob/master/shell/key-bindings.bash
_fzf_script_functions() {
  local sf_name=$(_list_script_functions | fzf)
  READLINE_LINE="$sf_name"
  READLINE_POINT=$((${#sf_name}))
}
