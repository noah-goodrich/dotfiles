# Noah — Personal Preferences

## Communication
- I think in systems. When explaining trade-offs, use the 80/20 frame.
- I prefer CLI-first solutions over GUI.
- When I say "simple", I mean fewest moving parts, not fewest lines.
- Show me the command I need to run, don't just describe it.
- Chain commands with && or ; so I can copy-paste one block.

## Code Style
- Python: black formatting, type hints on public functions
- SQL: uppercase keywords, lowercase identifiers, CTEs over subqueries
- Shell: zsh, prefer functions over aliases for anything > 1 line
- 4-space indentation everywhere except YAML/Lua (2-space)

## Permissions
- **Never accept project-level permission prompts.** When Claude Code offers "Yes, and allow X", always choose plain "Yes" instead. All permissions are managed globally in `~/.claude/settings.json`. Project-level `settings.local.json` files should have empty allow lists. Do not add permissions to project-level settings.

## Bash Tool Rules
- **No inline `#` comments in one-liner bash commands.** Quotes inside comments confuse the shell parser and trigger approval prompts. Use self-documenting echo statements or multi-step tool calls instead.
- **No temp scripts.** Don't `cat > /tmp/foo.sh && bash foo.sh`. Inline the logic as a `for`/`while` loop or use built-in tools (Glob, Grep, Read).
- **Always use absolute paths, never `~`.** Permission prefix matching is literal — `find ~/dev` doesn't match `Bash(find:*)` the same way `find /Users/noahgoodrich/dev` does.
- **Use `git -C /path`** instead of `cd /path && git ...`. The permission system matches on command prefix.
- **Never use `$()` command substitution in Bash tool calls.** The shell parser flags it as dangerous and triggers approval prompts. Instead:
  - `$(basename "$x")` → pipe to `basename` or use `${x##*/}` parameter expansion
  - `$(dirname "$x")` → use `${x%/*}` parameter expansion
  - `$(wc -l < file)` → pipe: `cat file | wc -l`
  - `$(command)` in echo → break into separate tool calls or use a variable set earlier in the pipeline
  - If substitution is truly unavoidable, use a `for` loop with the variable set via pipe: `... | while read -r val; do echo "$val"; done`

## Environment
- macOS, Apple Silicon (arm64)
- Terminal: Ghostty
- Editor: Neovim (Kickstart-based config)
- Multiplexer: tmux (Ctrl+Space prefix)
- Shell: zsh with powerlevel10k
- Devcontainers for project isolation (Docker Compose)

## Dotfiles
- Repo: ~/.config/dotfiles (symlinked to standard locations)
- Cheatsheets: ~/.config/dotfiles/nvim/neovim-cheatsheet.md
                ~/.config/dotfiles/tmux/tmux-cheatsheet.md
- Dev CLI: ~/dev/dev.sh (aliased as `dev`)

## When I Say...
- "dev environment" → devcontainer via docker compose
- "cortex" → Snowflake's Cortex Code CLI (like Claude Code but for Snowflake)
- "the meetup" → Snowflake Utah community meetup

## Session Continuity
If a previous session was compacted, context is at @~/.claude/handovers/latest.md

## Active Skills
@~/.config/dotfiles/claude/plugins/token-cost/skills/token-cost/SKILL.md
