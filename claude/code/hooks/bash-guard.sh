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
    *"curl"*"| bash"*|*"wget"*"| bash"*|*"curl"*"| sh"*)
        echo "Blocked: piping remote script to shell" >&2
        exit 2
        ;;
esac

exit 0
