#!/usr/bin/env bash
# Usage: dev [project-path]
# Creates a named tmux session with: Neovim (left) | Claude Code (top-right) | Terminal (bottom-right)

SESSION="${2:-dev}"
PROJ="${1:-$PWD}"

# Attach if session already exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
  exit 0
fi

# Window 1: code — three-pane layout
tmux new-session -d -s "$SESSION" -c "$PROJ" -x "$(tput cols)" -y "$(tput lines)"
tmux rename-window -t "$SESSION:1" "code"

# Split: right pane at 38% width
tmux split-window -h -t "$SESSION:1" -p 38 -c "$PROJ"
# Split right pane: terminal at bottom 40%
tmux split-window -v -t "$SESSION:1.2" -p 40 -c "$PROJ"

# Start processes
tmux send-keys -t "$SESSION:1.1" "nvim ." Enter       # left: Neovim
tmux send-keys -t "$SESSION:1.2" "claude" Enter        # top-right: Claude Code
# bottom-right stays as a free shell

# Window 2: server/logs (free)
tmux new-window -t "$SESSION" -n "server" -c "$PROJ"

# Focus left pane (Neovim)
tmux select-window -t "$SESSION:1"
tmux select-pane -t "$SESSION:1.1"

tmux attach -t "$SESSION"
