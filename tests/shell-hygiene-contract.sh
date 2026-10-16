#!/usr/bin/env bash
# Contract for the shell-command guidance in claude/code rule files.
# Usage: shell-hygiene-contract.sh [repo-root]
# Optional: BORG_MANAGED_MD=/path/to/borg-managed.md also scans that file
# (the retired wrap rule lives there; it is owned by another slice).
# Self-test: the "absent" patterns must hit the old-rule fixture, so they
# are proven non-vacuous; the "present" patterns are anchored to CLAUDE.md.
set -u
root="${1:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel)}"
claude="$root/claude/code/CLAUDE.md"
scan=("$claude" "$root/cortex/RULES.md")
[ -n "${BORG_MANAGED_MD:-}" ] && scan+=("$BORG_MANAGED_MD")
fixture="$root/tests/fixtures/old-wrap-rule.md"
fail=0

absent() { # desc, pattern: must NOT match scanned files, MUST match fixture
    local desc="$1" pat="$2"
    if ! grep -qiE -- "$pat" "$fixture"; then
        echo "FAIL (vacuous, misses old-rule fixture): $desc"; fail=1; return
    fi
    if grep -qiE -- "$pat" "${scan[@]}"; then
        echo "FAIL: $desc"; fail=1
    else
        echo "ok: $desc"
    fi
}
absent_plain() { # desc, pattern: must NOT match scanned files
    if grep -qiE -- "$2" "${scan[@]}"; then echo "FAIL: $1"; fail=1; else echo "ok: $1"; fi
}
present() { # desc, pattern: must match cortex/RULES.md (CLAUDE.md defers to borg-managed.md)
    if grep -qiE -- "$2" "$root/cortex/RULES.md"; then echo "ok: $1"; else echo "FAIL: $1"; fail=1; fi
}

absent "no table row mapping a pipe/env/&& chain to bash -c" '\|.*`bash -c '
absent "no 'Use it for pipelines' prescription" 'use it for pipelines'
absent "no wrap-for-pipelines rule" "bash -c '\.\.\.'\` for pipelines"
absent_plain "no env-wrapper advice" 'env VAR=val'
absent_plain "no blanket never-split-or-script ban" 'never respell, split or script'
absent_plain "no respelled removal advice" '\[r\]m|respell(ing)? (the|a) removal word to'

present "states per-subcommand matching" 'matched per subcommand'
present "states literal paths for deletions" 'literal paths'
present "states bash -c only for a lone loop/conditional" 'only for a lone loop'
present "warns on nested \$(...) / loop / heredoc plain shapes" 'nested `\$\(\.\.\.\)`'
present "mixed scripts must be split" 'split it into separate plain calls'
present "bans evasion, allows separate calls" 'obfuscating the target'
exit "$fail"
