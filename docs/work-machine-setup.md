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
- Reinstalls all 7 noah-local plugins: `borg-collective`, `dev-tools`, `noah-content-tools`,
  `noah-strategy`, `noah-writing-voice`, `research-tools`, `token-cost`.
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
# Expected: 8 plugins (7 from noah-local + claude-code-setup)

# Marketplace points at the new location
claude plugin marketplace list
# Expected: noah-local → Directory (~/dev/claude-plugins)

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
for p in borg-collective dev-tools noah-content-tools noah-strategy noah-writing-voice research-tools token-cost; do
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

---

## Secrets matrix

All secrets are loaded from macOS Keychain by `zsh/secrets.zsh`. The Keychain service name matches
the env var name in every case. On a fresh work machine, provision only the entries marked
**provision** below. Do **not** provision personal API keys on a corporate-managed device.

| Env Var | Work machine | Notes |
|---------|--------------|-------|
| `ANTHROPIC_SDK_KEY` | **skip** | Claude Code uses Max subscription. Do not put a personal key on a corporate device. |
| `GOOGLE_API_KEY` | **provision** | Work Google API access. |
| `JIRA_API_TOKEN` | **provision** | Atlassian Jira API token for work account. |
| `JIRA_USERNAME` | **provision** | Jira account email (`ngoodrich@ontra.ai`). |
| `JIRA_URL` | **provision** | Work Jira site (e.g. `https://ontra.atlassian.net`). |
| `NEXUS_HOST` | **provision** | Nexus hostname — see Step 3 above (`facts.ontra.tools`). |
| `NEXUS_USERNAME` | **provision** | Nexus artifact repo user token name. |
| `NEXUS_TOKEN` | **provision** | Nexus artifact repo token. |
| `SNOWFLAKE_PAT` | **provision** | Snowflake PAT for Cortex Code CLI. Use the work Snowflake account. |
| `SUPABASE_ACCESS_TOKEN` | **different value** | Provision a work-specific token, not the personal one. |
| `REVEAL_SUPABASE_DB_PASSWORD` | **skip** | stillpoint-labs/reveal is a personal project. |
| `REVEAL_SUPABASE_ANON_KEY` | **skip** | stillpoint-labs/reveal — personal project. |
| `REVEAL_SUPABASE_SERVICE_ROLE_KEY` | **skip** | stillpoint-labs/reveal — personal project (bypasses RLS). |
| `INGLE_SUPABASE_DB_PASSWORD` | **skip** | stillpoint-labs/ingle — personal project. |
| `FLY_API_TOKEN` | **skip** | Fly.io personal account; no work apps. |
| `CLOUDFLARE_API_TOKEN` | **skip** | Cloudflare DNS/Workers for ingle (personal project). |
| `CLOUDFLARE_ACCOUNT_ID` | **skip** | Cloudflare account ID (ingle, personal). |
| `PORKBUN_API_KEY` | **skip** | Porkbun domain registrar (ingle, personal). |
| `PORKBUN_SECRET_KEY` | **skip** | Porkbun domain registrar (ingle, personal). |

### Cairn knowledge graph (optional)

Cairn is the optional PostgreSQL + pgvector knowledge persistence layer used by borg. On the work
machine, cairn runs without its LLM legs — debrief summarization is a no-op, but knowledge storage
and vector search still work.

| Secret | Work machine | Notes |
|--------|--------------|-------|
| `cairn-anthropic-key` (Keychain) | **skip** | Unset = cairn LLM legs disabled. Intended work-machine state. |
| Cairn Postgres password | **provision** | Set via `POSTGRES_PASSWORD` in cairn's compose file. Work-specific value. |
