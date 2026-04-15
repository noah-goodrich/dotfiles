# Project Plan: Dotfiles Settings Stratification + Plugin Extraction
*Established: 2026-04-15*
*Shipped: 2026-04-15 — committed directly to main (no PR; single-developer repo)*

## Objective
Eliminate multi-machine config drift in `git/config` and `.zshrc`, and extract Claude Code plugins
into their own repo (`claude-plugins`) so dotfiles commits stay focused on shell/editor config.

## Acceptance Criteria

- [x] **Git identity is not tracked in dotfiles.** `git/config` contains no email. Identity resolves
      via a conditional `include` pointing at a gitignored, machine-local file.
  - Verify: `grep -i email /Users/noah/.config/dotfiles/git/config` returns nothing.
  - Verify: on each machine, `git -C <some-repo> commit --allow-empty -m test` records the correct
    email for that machine.

- [x] **`.zshrc` has no environment-specific logic.** The `/workspace/.venv/bin/activate` line
      moves to `local.zsh` (host) or a container-provisioned file (devcontainer). Future
      container-only bits go through the same channel.
  - Verify: `grep -E '(workspace|venv)' /Users/noah/.config/dotfiles/zsh/.zshrc` returns nothing.

- [x] **Plugins live in a new `claude-plugins` repo.** `claude/plugins/` is removed from dotfiles.
      The new repo (`github.com/noah-goodrich/claude-plugins`) holds the 5 plugin directories.
      Clean-slate initial commit (no history migration).
  - Verify: `ls /Users/noah/.config/dotfiles/claude/plugins` errors or is empty.
  - Verify: `gh repo view noah-goodrich/claude-plugins` succeeds and the repo contains
    `dev-tools/`, `noah-content-tools/`, `noah-strategy/`, `noah-writing-voice/`, `token-cost/`.

- [x] **`install.sh` clones/updates `claude-plugins` and points the `noah-local` marketplace at the
      clone.** Build script (`build-plugins.sh`) and any patch-bump logic move into the plugin repo.
  - Verify: fresh install on this machine ends with `claude plugin list` showing all 5 plugins, and
    `jq -r '.extraKnownMarketplaces["noah-local"].source.path' ~/.claude/settings.json` points at
    the cloned `claude-plugins` location.

- [x] **`secrets.zsh` stops hardcoding `facts.ontra.tools`.** The PIP index block reads the host
      from a keychain entry (e.g. `NEXUS_HOST`) and is a no-op when unset.
  - Verify: `grep facts.ontra.tools /Users/noah/.config/dotfiles/zsh/secrets.zsh` returns nothing.

- [x] **Nothing-breaks regression.** Running `install.sh` on this machine after the changes:
  - leaves `git -C /Users/noah/.config/dotfiles status --porcelain` clean,
  - does not remove any currently-installed plugin (`claude plugin list` count unchanged),
  - leaves the working git identity intact for both personal and work repos this machine touches.

## Scope Boundaries

- **NOT** migrating to chezmoi, nix, or home-manager.
- **NOT** rewriting `install.sh` symlink logic or `merge_claude_settings` jq.
- **NOT** introducing a new secrets manager — keychain stays.
- **NOT** deleting `dev.sh` legacy or other unrelated cleanup.
- **NOT** carrying plugin git history forward — clean-slate commit in the new repo.
- **If done early:** ship. Don't expand.

## Ship Definition

1. Changes committed and pushed on `main` in **both** repos: `dotfiles` and `claude-plugins`.
2. `claude-plugins` repo created on GitHub under `noah-goodrich/`.
3. `install.sh` run on this machine completes with `git status --porcelain` clean.
4. `claude plugin list` shows all 5 plugins after install.
5. A test commit in any repo on this machine uses the correct email for that working tree.
6. Same verification steps repeated on the work machine (separate session — out of scope for
   *finishing* this plan; in scope for declaring victory across both machines).

## Timeline
Target: this session (~2 hours on this machine). Work-machine rollout is a follow-up session,
expected to be <30 minutes since it's just `git pull` + `install.sh`.

## Risks

1. **Plugin version monotonicity across the split.** After the move, the first build on the *other*
   machine will bump from whatever's checked into the new repo, not from whatever's installed
   locally — a downgrade is possible. Mitigation: freeze versions, drop the auto-bump from
   `build-plugins.sh`, bump manually when shipping a real change.

2. **Conditional-include key choice.** `includeIf "gitdir:..."` only matches when the working tree
   sits under a specific prefix. Need to look at actual repo layout on both machines before
   choosing between `gitdir:` and `hasconfig:remote.*.url:git@github.com:ontra-*/**`. Hostname-based
   match (`includeIf "hostname:..."`) is the most robust but requires git ≥ 2.36.

3. **Existing `~/.claude/settings.json` has the old marketplace path baked in.**
   `merge_claude_settings` re-injects the path on every install, so the update should be automatic
   — but Claude Code may cache marketplace state. First install after the change may need a manual
   `claude plugin marketplace remove noah-local` beforehand. Document the recovery command.

## Additional Work Shipped

- `docs/work-machine-setup.md` — step-by-step guide for rolling out this change on the work
  machine. Written for Claude to execute directly, covering git identity, Nexus keychain entry,
  `install.sh`, and verification commands with expected outputs. Includes recovery steps for the
  known marketplace caching issue.
- `install.sh` simplify fixes: collapsed `chmod +x` + `[ -x ]` TOCTOU pattern; restructured
  `command -v claude` double-check into single `if/elif` branch; moved `ensure_gitconfig_local`
  to correct position in file before the `# Main` section header.
