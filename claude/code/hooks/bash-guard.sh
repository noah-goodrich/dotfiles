#!/usr/bin/env bash
# PreToolUse hook (Bash) — block obviously dangerous commands.
# Exit 2 = block the command and tell Claude why.

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin 2>/dev/null) || exit 0

case "$COMMAND" in
    *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf \$HOME"*)
        echo "Blocked: recursive delete of home or root directory" >&2
        exit 2
        ;;
    *"chmod -R 777"*)
        echo "Blocked: world-writable recursive chmod" >&2
        exit 2
        ;;
    *"> /dev/sda"*|*"dd if="*"of=/dev/"*)
        echo "Blocked: raw disk write" >&2
        exit 2
        ;;
    *"curl"*"| bash"*|*"wget"*"| bash"*|*"curl"*"| sh"*|*"wget"*"| sh"*)
        echo "Blocked: piping remote script to shell" >&2
        exit 2
        ;;
    *"curl"*"-X POST"*|*"curl"*"-X PUT"*|*"curl"*"-X DELETE"*|*"curl"*"-X PATCH"*|*"curl"*"-d "*|*"curl"*"--data"*|*"curl"*"--upload"*|*"curl"*"-F "*|*"curl"*"--form"*)
        echo "Blocked: curl with write method — GET only" >&2
        exit 2
        ;;
    *"rm -rf"*".claude"*)
        echo "Blocked: recursive delete of Claude settings directory" >&2
        exit 2
        ;;
    *"git push --force"*" main"*|*"git push --force"*" master"*|*"git push -f "*" main"*|*"git push -f "*" master"*)
        echo "Blocked: force push to main/master — use --force-with-lease or push to a branch" >&2
        exit 2
        ;;
    *"> ~/.claude/settings.json"*|*">\$HOME/.claude/settings.json"*|*"> /Users/"*"/.claude/settings.json"*)
        echo "Blocked: truncating Claude settings file" >&2
        exit 2
        ;;
esac

exit 0
