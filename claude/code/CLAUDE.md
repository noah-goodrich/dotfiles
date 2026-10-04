# Noah — Personal Preferences

## Communication
- I think in systems. When explaining trade-offs, use the 80/20 frame.
- I prefer CLI-first solutions over GUI.
- When I say "simple", I mean fewest moving parts, not fewest lines.
- Show me the command I need to run, don't just describe it.
- Chain commands with && or ; so I can copy-paste one block.

## Markdown / Doc Generation
- Hard-wrap only where a line-oriented tool reads the text; never where a renderer or terminal reflows it.
  - Never hard-wrap: PR descriptions, PR/issue/review comments, any `gh` body, release notes, chat replies, posts for
    Slack/Jira/LinkedIn, and anything bound for pandoc or epub. Write one line per paragraph or bullet.
  - Markdown files: do not hard-wrap new prose. When editing an existing hard-wrapped paragraph, match its wrap and do
    not reflow neighbors. Never wrap URLs.
  - Markdown FILES read in a terminal or editor: tables and fenced blocks (mocks, code, diagrams) cannot reflow, so
    every table row and fenced line stays within 72 columns. Keep table cells to a few words and put longer text in
    bullets below the table; if a table needs more width, it should be a list. (GitHub-rendered text wraps table cells
    itself, so no table limit applies to PR bodies and comments.)
  - Source code and its comments: the project's configured limit (ruff/pylint/black); 120 where none is configured.
  - Git commit messages: subject <= 72 characters, body wrapped at 72.

## Code Style
- Python: black formatting, type hints on public functions
- SQL: uppercase keywords, lowercase identifiers, CTEs over subqueries
- Shell: zsh, prefer functions over aliases for anything > 1 line
- 4-space indentation everywhere except YAML/Lua (2-space)
- Markdown/text: no hard-wrap (see Markdown / Doc Generation).

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

## Borg-managed rules
@~/.claude/borg-managed.md
