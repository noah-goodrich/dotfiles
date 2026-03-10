# dotfiles

Personal development environment configuration for Noah Goodrich.

## What's in here

| Directory | Maps to | Purpose |
|-----------|---------|---------|
| `tmux/` | `~/.config/tmux/` | tmux config — Ctrl+Space prefix, vim navigation |
| `zsh/` | `~/` | zshrc — Powerlevel10k, autosuggestions, aliases |
| `git/` | `~/.gitconfig` + `~/.config/git/ignore` | Git config and global gitignore |
| `nvim/` | `~/.config/nvim/` | Neovim config (Kickstart-based) |
| `ghostty/` | `~/.config/ghostty/` | Ghostty terminal — Catppuccin Mocha, JetBrainsMono Nerd Font |
| `claude/` | built to `claude/dist/` | Claude plugins — voice, AI scoring, content tools, token cost |


## New machine setup

```bash
# 1. Clone the repo
git clone https://github.com/noah-goodrich/dotfiles ~/.config/dotfiles

# 2. Run the install script
cd ~/.config/dotfiles
chmod +x install.sh
./install.sh

# 3. Configure Powerlevel10k prompt
p10k configure

# 4. Set your git email
git config --global user.email "your@email.com"
```

## Devcontainer

The `devcontainer.json` dotfiles integration will clone this repo and run
`install.sh` automatically on container creation. No manual steps needed.

## Key bindings summary

### tmux (prefix: Ctrl+Space)

| Key | Action |
|-----|--------|
| `Ctrl+Space \|` | Split vertical |
| `Ctrl+Space -` | Split horizontal |
| `Ctrl+Space h/j/k/l` | Navigate panes |
| `Ctrl+Space c` | New window |
| `Ctrl+Space ,` | Rename window |
| `Ctrl+Space d` | Detach session |
| `Ctrl+Space r` | Reload config |

### Zsh aliases

| Alias | Command |
|-------|---------|
| `v` | nvim |
| `t` | tmux |
| `ta` | tmux attach -t |
| `tn` | tmux new -s |
| `gs` | git status |
| `gl` | git log --oneline --graph |

## Claude plugins

Custom skills for Claude (Cowork, Claude Code, claude.ai). Source lives in `claude/plugins/`, built into `.plugin` files by `install.sh` or manually via `claude/build-plugins.sh`.

| Plugin | Skills | Purpose |
|--------|--------|---------|
| `noah-writing-voice` | noah-voice, ai-scoring | Voice enforcement + AI detection scoring |
| `noah-content-tools` | linkedin-post, snowflake-article | Platform-specific content creation (depends on writing-voice) |
| `token-cost` | token-cost | Token/cost estimation on every response (standalone) |

**Installing plugins:** After building, drag the `.plugin` files from `claude/dist/` into a Cowork chat or use the "Copy to your skills" button. Plugins are session-scoped in Cowork, so you'll re-install when starting fresh sessions.

**Editing skills:** Edit the source files in `claude/plugins/*/skills/`, then rebuild with `claude/build-plugins.sh`.

## Adding new dotfiles

1. Add the config file to the appropriate directory in this repo
2. Add a `link` line to `install.sh`
3. Run `./install.sh` to apply
4. Commit and push
