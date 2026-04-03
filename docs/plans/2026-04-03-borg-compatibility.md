# Project Plan: Borg Compatibility
*Established: 2026-04-03*
*Shipped: 2026-04-03 — PR #1 merged to main*

## Objective
Make the dotfiles repo compatible with the borg-collective orchestrator — settings.json is merged
(not clobbered), the container user switches from `vscode` to `dev`, hooks/commands are copied (not
symlinked) for devcontainer compatibility, `dev.sh` integrates `borg add`/`borg next`, and a new
`noah-strategy` plugin is added.

## Acceptance Criteria
- [x] settings.json merge works non-destructively (borg hooks survive install.sh re-runs)
  - Verify: `bash install.sh && jq '.hooks' ~/.claude/settings.json` (confirm borg hooks present)
- [x] Container user is `dev` throughout — no `vscode` references in devcontainer or template files
  - Verify: `grep -r 'vscode' devcontainer/ claude/plugins/dev-tools/skills/bootstrap-project/references/`
    returns nothing
- [x] Hooks and commands are copied, not symlinked
  - Verify: `bash install.sh && file ~/.claude/hooks/bash-guard.sh` shows "regular file"
- [x] dev.sh borg integration — `dev up` calls `borg add`, `dev restart --all` works, tmux `>`
  keybinding invokes `borg next --switch`
  - Verify: `grep -c 'borg' dev.sh tmux/tmux.conf` shows matches in both files
- [x] bash-guard blocks dangerous patterns (force-push main, protect .claude dir, settings.json truncate)
  - Verify: `echo '{"command":"git push --force origin main"}' | bash claude/code/hooks/bash-guard.sh`
    exits 2
- [x] No regression: core dotfile symlinks (tmux, zsh, nvim, ghostty, git) still work after install
  - Verify: `bash install.sh && readlink ~/.tmux.conf` points into dotfiles repo

## Scope Boundaries
- NOT building: borg-collective itself (separate repo, we only integrate)
- NOT building: devcontainer rebuild/test of `dev` user across all existing projects (follow-up)
- NOT building: noah-strategy plugin content (ships as-is or excluded)
- If done early: Ship, don't expand.

## Ship Definition
PR opened from `borg-compat` to `main` -> manual verification passes -> merged.

## Timeline
Target: this session
Estimated effort: 1 session, ~1 hour (most changes already written)

## Risks
- settings.json merge jq logic is complex — union-hooks strategy may have edge cases with duplicate
  detection. Manual test with real borg-managed settings.json recommended.
- `vscode` to `dev` rename will break running containers — existing projects need rebuild after merge.
- Hooks as copies diverge from source — users must re-run install.sh to pick up dotfile hook changes.

## Additional Work Shipped
- `notify.sh`: show tmux window name in notification subtitle; background `afplay` to avoid blocking
- `post-tool-format.sh`: extended to lint markdown files for 120-char line length violations
- `noah-strategy` plugin added (strategic-brief skill with 9-step analytical framework)
- `ANTHROPIC_API_KEY` renamed to `ANTHROPIC_SDK_KEY` in `secrets.zsh`
