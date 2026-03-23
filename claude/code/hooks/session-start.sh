#!/usr/bin/env bash
# SessionStart hook — inject project context so Claude knows where we are.
# Feeds git status, recent commits, docker/tmux state into the session.

set -euo pipefail

context=""

# Git context (if in a repo)
if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    status=$(git status --short 2>/dev/null | head -20)
    recent=$(git log --oneline -5 2>/dev/null)

    context+="Git branch: $branch"$'\n'
    if [ -n "$status" ]; then
        context+="Uncommitted changes:"$'\n'"$status"$'\n'
    fi
    context+="Recent commits:"$'\n'"$recent"$'\n'
fi

# Docker status (if dev environment)
container=$(docker ps --filter "label=dev.role=app" --format '{{.Names}}' 2>/dev/null | head -1 || true)
if [ -n "$container" ]; then
    context+="Devcontainer running: $container"$'\n'
fi

# tmux session info
if tmux has-session -t dev 2>/dev/null; then
    windows=$(tmux list-windows -t dev -F "#I:#W" 2>/dev/null | tr '\n' ', ')
    context+="tmux session 'dev' active — windows: $windows"$'\n'
fi

# Output as JSON for Claude to consume
if [ -n "$context" ]; then
    jq -n --arg ctx "$context" '{
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": $ctx
        }
    }'
fi

exit 0
