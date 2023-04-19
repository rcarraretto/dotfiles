#!/usr/bin/env bash

# To re-test:
# rm /var/tmp/session_timestamp.txt; tmux kill-server
__tmux_startup() {
  if [ -n "$MAC_BOOTED" ]; then
    # this is for skipping the checks in new panes in a tmux session
    echo "$(date "+%Y-%m-%d %H:%M") mac already booted" >> /var/tmp/tmux_startup_log.txt
    return
  fi
  if [ -n "$TMUX" ]; then
    # already in tmux
    echo "$(date "+%Y-%m-%d %H:%M") already in tmux" >> /var/tmp/tmux_startup_log.txt
    return
  fi
  local previous_timestamp=$(cat /var/tmp/session_timestamp.txt 2> /dev/null)
  local session_timestamp=$(finger -l | perl -lne 'print $1 if /On since (.*) on console/')
  if [ "$session_timestamp" = "$previous_timestamp" ]; then
    echo "$(date "+%Y-%m-%d %H:%M") same timestamp $previous_timestamp $session_timestamp" >> /var/tmp/tmux_startup_log.txt
    return
  fi
  export MAC_BOOTED=1
  echo "$session_timestamp" > /var/tmp/session_timestamp.txt
  # Note: Reattach is possible when logging out and in again
  # But vim * register doesn't work. Vim has to be restarted.
  echo "$(date "+%Y-%m-%d %H:%M") tmux $previous_timestamp $session_timestamp" >> /var/tmp/tmux_startup_log.txt
  # To see the output of dot_pull when already inside tmux, detach tmux (prefix + d)
  dot_pull
  __tmux_default_session
  # After this line, we are already in tmux, so apparently commands don't get executed.
}

__tmux_default_session() {
  if [ -n "$TMUX" ]; then
    echo "tmux_default_session: already inside tmux"
    return 1
  fi
  local session='main'
  if tmux attach -t $session &> /dev/null; then
    return
  fi
  local working_dir="$HOME/work"
  if [ -f "$PROJECT_CONF" ]; then
    local project_path=$(head -1 "$PROJECT_CONF")
    # Note: Cannot use tilde in paths in projects.txt
    if [ -d "$project_path" ]; then
      local working_dir="$project_path"
    fi
  fi
  tmux new-session -s $session -c "$working_dir" -d 'vim .' \; \
    new-window -t $session \; \
    select-window -t $session:1 \;
  tmux attach -t $session
}
