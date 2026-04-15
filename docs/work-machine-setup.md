# Work Machine Setup Guide

This guide brings a work machine into sync after dotfiles changes. Safe to run on an already-configured
machine — nothing is destructive.

**For Claude:** Execute each step in order. Show output. Pause at any step that produces an error
before continuing.

---

## Context

This dotfiles repo uses a layered config strategy:

- **Shared** (`~/.config/dotfiles`, tracked): shell, editor, git aliases, Claude Code config.
- **Machine-local** (`~/.gitconfig.local`, gitignored): identity — name, email.
- **Secret** (macOS Keychain → `zsh/secrets.zsh`): API keys, Nexus credentials.
- **Plugins** (`~/dev/claude-plugins`, separate repo): Claude Code plugins, installed by `install.sh`.

The work machine identity is `ngoodrich@ontra.ai`. Personal machine uses `goodrich.noah@gmail.com`.

---

## Steps

### 1. Pull latest dotfiles

```bash
git -C ~/.config/dotfiles pull --ff-only
```

Expected: fast-forward or "Already up to date."

---

### 2. Set work email in machine-local gitconfig

This file is gitignored — it never gets committed. `install.sh` creates a stub if it doesn't
exist, but it's faster to set the value directly:

```bash
git config -f ~/.gitconfig.local user.email 'ngoodrich@ontra.ai'
```

Verify:

```bash
git config user.email
```

Expected output: `ngoodrich@ontra.ai`

---

### 3. Store Nexus host in Keychain

The Nexus URL hostname moved out of `secrets.zsh` into the Keychain. If `PIP_INDEX_URL` was
previously set on this machine, the host is `facts.ontra.tools`:

```bash
security add-generic-password -s NEXUS_HOST -a "$USER" -w "facts.ontra.tools" -U
```

The `-U` flag updates the entry if it already exists.

Verify:

```bash
security find-generic-password -s NEXUS_HOST -a "$USER" -w
```

Expected output: `facts.ontra.tools`

---

### 4. Run install.sh

```bash
bash ~/.config/dotfiles/install.sh
```

What this does on the work machine:

- Skips `~/.gitconfig.local` stub (already set in step 2).
- Clones `https://github.com/noah-goodrich/claude-plugins` to `~/dev/claude-plugins` if not
  present; otherwise pulls latest.
- Re-registers the `noah-local` Claude Code marketplace pointing at `~/dev/claude-plugins`
  (replaces the old path that pointed at `dotfiles/claude/plugins`).
- Reinstalls all 5 plugins: `dev-tools`, `noah-content-tools`, `noah-strategy`,
  `noah-writing-voice`, `token-cost`.
- Merges Claude Code `settings.json` (non-destructive — preserves existing hooks and permissions).
- Rebuilds the `devcontainer-base:local` Docker image.
- Reloads `.zshrc` in all open tmux panes.

---

## Verification Checklist

Run these after `install.sh` completes:

```bash
# Git identity resolves correctly for this machine
git config user.email
# Expected: ngoodrich@ontra.ai

# No hardcoded email in tracked config
grep -i email ~/.config/dotfiles/git/config
# Expected: only comment lines

# Plugins installed
claude plugin list
# Expected: 6 plugins (5 from noah-local + claude-code-setup)

# Marketplace points at the new location
claude plugin marketplace list
# Expected: noah-local → Directory (~//dev/claude-plugins)

# Nexus credentials load correctly (non-empty means keychain worked)
source ~/.zshrc && echo "${PIP_INDEX_URL:0:30}..."
# Expected: https://... (not empty)
```

---

## If Something Goes Wrong

**`claude plugin install` fails with "not found in marketplace":**

The marketplace may be cached at the old path. Force a re-registration:

```bash
claude plugin marketplace remove noah-local
claude plugin marketplace add ~/dev/claude-plugins
```

Then re-run the plugin installs:

```bash
for p in dev-tools noah-content-tools noah-strategy noah-writing-voice token-cost; do
    claude plugin install "${p}@noah-local"
done
```

**`git pull` has conflicts:**

The work machine had uncommitted changes. Stash, pull, re-apply:

```bash
git -C ~/.config/dotfiles stash
git -C ~/.config/dotfiles pull --ff-only
git -C ~/.config/dotfiles stash pop
```

Resolve any conflicts, then run `install.sh`.

**Docker build fails:**

Non-fatal for day-to-day use. Run `drone up <project>` to rebuild when needed.
