#!/usr/bin/env bash
# post-tool-format.sh — auto-format Python files after Write/Edit

INPUT=$(cat /dev/stdin 2>/dev/null || true)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || true)

[ -f "$FILE" ] || exit 0

if [[ "$FILE" == *.py ]]; then
    if command -v ruff &>/dev/null; then
        ruff format "$FILE" --quiet 2>/dev/null || true
    elif command -v black &>/dev/null; then
        black "$FILE" --quiet 2>/dev/null || true
    fi
fi

exit 0
