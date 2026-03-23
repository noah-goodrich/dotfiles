#!/usr/bin/env bash
# Stop hook — append a one-line session entry to ~/.claude/session-log.md
# Answers: "what did I work on and when?"
#
# Claude Code sends JSON on stdin with: session_id, cwd, transcript_path

LOG_FILE="$HOME/.claude/session-log.md"

# Read stdin safely — if empty or malformed, fall back to defaults
INPUT=$(cat /dev/stdin 2>/dev/null || true)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null || echo "unknown")

echo "- $(date '+%Y-%m-%d %H:%M') | $CWD | session:$SESSION_ID" >> "$LOG_FILE"

exit 0
