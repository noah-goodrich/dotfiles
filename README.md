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

## Claude skills

Custom skills for Claude, with a unified build system that targets both Cowork/Claude Code (plugins) and claude.ai (Project instructions). All source lives in `claude/plugins/`; build scripts produce the right artifacts for each platform.

### Layout

```
claude/
├── plugins/                  # Skill source (single source of truth)
│   ├── noah-writing-voice/   # noah-voice + ai-scoring
│   ├── noah-content-tools/   # linkedin-post + snowflake-article
│   └── token-cost/           # token/cost estimation
├── project/                  # Project-specific context files
│   └── snowflake-builders-blog.md
├── build-plugins.sh          # → dist/*.plugin   (Cowork / Claude Code)
├── build-project.sh          # → dist/writing-rules.md + dist/project-context.md (claude.ai)
└── dist/                     # Built artifacts (gitignored)
```

### Plugins (Cowork / Claude Code)

| Plugin | Skills | Purpose |
|--------|--------|---------|
| `noah-writing-voice` | noah-voice, ai-scoring | Voice enforcement + AI detection scoring |
| `noah-content-tools` | linkedin-post, snowflake-article | Platform-specific content creation (depends on writing-voice) |
| `token-cost` | token-cost | Token/cost estimation on every response (standalone) |

**Installing:** Drag `.plugin` files from `claude/dist/` into a Cowork chat or use "Copy to your skills." Plugins are session-scoped in Cowork, so re-install when starting fresh sessions.

### Project instructions (claude.ai)

`build-project.sh` extracts writing rules from the plugin sources and combines them into two files for claude.ai Projects:

| Output | Goes in | Purpose |
|--------|---------|---------|
| `dist/writing-rules.md` | Project custom instructions | Voice rules, AI scoring, LinkedIn/article conventions, token cost |
| `dist/project-context.md` | Project knowledge file (upload) | Series state, visual style, snowfort details — project-specific context |

**Setup for a claude.ai Project:**

1. Run `bash claude/build-project.sh` (or just `./install.sh`)
2. Paste the contents of `dist/writing-rules.md` into the Project's custom instructions
3. Upload `dist/project-context.md` as a Project knowledge file

To use a different project context file: `bash claude/build-project.sh claude/project/other-project.md`

### Editing skills

Edit source files in `claude/plugins/*/skills/`, then rebuild:

```bash
# Rebuild everything
./install.sh

# Or rebuild individually
bash claude/build-plugins.sh     # .plugin files only
bash claude/build-project.sh     # claude.ai files only
```

## Adding new dotfiles

1. Add the config file to the appropriate directory in this repo
2. Add a `link` line to `install.sh`
3. Run `./install.sh` to apply
4. Commit and push
