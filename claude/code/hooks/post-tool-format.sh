#!/usr/bin/env bash
# post-tool-format.sh — after Write/Edit: auto-format Python; warn on wide markdown tables/fences

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

# Tables and fenced blocks cannot reflow in a terminal/editor pane: flag rows/lines > 72 columns.
# Prose is never flagged. Count characters, not bytes (box-drawing glyphs are multibyte).
if [[ "$FILE" == *.md ]]; then
    read -r -d '' PYSRC <<'PY' || true
import re, sys
out, fence = [], False
for n, line in enumerate(open(sys.argv[1], encoding="utf-8", errors="replace"), 1):
    line = line.rstrip("\n")
    if re.match(r"\s*(```|~~~)", line):
        fence = not fence
        continue
    if (fence or line.lstrip().startswith("|")) and len(line) > 72:
        out.append(f"{n}({len(line)})")
print(" ".join(out))
PY
    WIDE=$(python3 -c "$PYSRC" "$FILE" 2>/dev/null || true)
    if [ -n "$WIDE" ]; then
        MSG="$FILE: table rows / fenced lines over 72 columns (line(width)): ${WIDE}. Tables and fenced blocks cannot reflow in a terminal pane. Shorten table cells to a few words and move longer text into bullets below the table; if a table needs more width, make it a list."
        jq -n --arg m "$MSG" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$m}}'
    fi
fi

exit 0
