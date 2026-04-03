#!/usr/bin/env bash
# post-tool-format.sh — auto-format Python files and lint markdown line length after Write/Edit

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

if [[ "$FILE" == *.md ]]; then
    VIOLATIONS=$(awk '
        /^```/ { in_fence = !in_fence; next }
        in_fence { next }
        length($0) > 120 { print NR": "length($0)" chars: "substr($0,1,80)"..." }
    ' "$FILE")
    if [[ -n "$VIOLATIONS" ]]; then
        echo "WARNING: $FILE has lines exceeding 120 chars (reflow needed):"
        echo "$VIOLATIONS"
    fi
fi

exit 0
