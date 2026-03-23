#!/usr/bin/env bash
# notify.sh — alert when Claude finishes a turn and needs input

INPUT=$(cat /dev/stdin 2>/dev/null || true)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)
PROJECT=$(basename "${CWD:-$(pwd)}")

# macOS notification — louder sound, alert style set via System Settings → Notifications → Script Editor
vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 50)
osascript -e 'set volume output volume 85' 2>/dev/null || true
osascript -e "display notification \"Ready for input\" with title \"Claude Code — $PROJECT\"" 2>/dev/null || true
afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true
osascript -e "set volume output volume $vol" 2>/dev/null || true

# tmux visual bell — write directly to the pane's TTY so tmux sees it
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    pane_tty=$(tmux display-message -t "$TMUX_PANE" -p "#{pane_tty}" 2>/dev/null || true)
    [ -n "$pane_tty" ] && printf '\a' > "$pane_tty"
fi

exit 0
