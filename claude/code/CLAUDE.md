# Noah — Personal Preferences

## Communication
- I think in systems. When explaining trade-offs, use the 80/20 frame.
- I prefer CLI-first solutions over GUI.
- When I say "simple", I mean fewest moving parts, not fewest lines.
- Show me the command I need to run, don't just describe it.
- Chain commands with && or ; so I can copy-paste one block.

## Markdown / Doc Generation
- Wrap all generated markdown at 120 characters. No line should exceed 120 characters unless it's a URL or code block that can't be broken.

## Code Style
- Python: black formatting, type hints on public functions
- SQL: uppercase keywords, lowercase identifiers, CTEs over subqueries
- Shell: zsh, prefer functions over aliases for anything > 1 line
- 4-space indentation everywhere except YAML/Lua (2-space)
- Markdown/text: hard-wrap at 120 characters. No line may exceed 120 chars.

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
- Dev CLI: managed outside this repo (e.g. borg orchestrator)

## When I Say...
- "dev environment" → devcontainer via docker compose
- "cortex" → Snowflake's Cortex Code CLI (like Claude Code but for Snowflake)
- "the meetup" → Snowflake Utah community meetup

## Session Continuity
If a previous session was compacted, context is at @~/.claude/handovers/latest.md

## Active Skills
@/Users/noah/dev/claude-plugins/token-cost/skills/token-cost/SKILL.md

## Cortex Code CLI
@~/.config/dotfiles/claude/code/CORTEX_RULES.md
