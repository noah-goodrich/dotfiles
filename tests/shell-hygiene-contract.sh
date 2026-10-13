#!/usr/bin/env bash
# Contract for the shell-command guidance in claude/code rule files.
# Fails on the old wrap-everything-in-bash--c rule, passes on the narrowed rule.
set -u
root="${1:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel)}"
files=("$root/claude/code/CLAUDE.md" "$root/claude/code/CORTEX_RULES.md")
fail=0
check() { # desc, expected(0 present|1 absent), pattern
    local desc="$1" want="$2" pat="$3" hit=1
    grep -qiE -- "$pat" "${files[@]}" && hit=0
    if [ "$hit" -ne "$want" ]; then echo "FAIL: $desc"; fail=1; else echo "ok: $desc"; fi
}
check "no table row mapping a pipe/env/&& chain to bash -c" 1 '\|.*`bash -c '
check "no 'Use it for pipelines' prescription" 1 'use it for pipelines'
check "no 'for pipelines and compound commands' wrap rule" 1 "bash -c '\.\.\.'\` for pipelines"
check "states per-subcommand matching" 0 'matched per subcommand'
check "states literal paths for deletions" 0 'literal paths'
check "states genuine control flow for bash -c" 0 'genuine control flow'
check "no respelled removal advice" 1 '\[r\]m|respell(ing)? (the|a) removal word to'
exit "$fail"
