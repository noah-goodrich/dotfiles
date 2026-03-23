# tmux Cheatsheet
## Noah's Custom Config

---

## Starting Your Dev Environment

```bash
dev up           # start devcontainer + tmux session
dev down         # stop devcontainer + kill tmux session
dev status       # show container and session status
dev help         # full cheatsheet (tmux, nvim, git, keys)
dev help tmux    # tmux section only
```

`dev up` does this:
- Navigates to `~/dev/snowflake-projects`
- Starts `docker compose` services if not running
- Creates a tmux session with 2 windows (dev + host)
- Drops you into the container shell

Override the project dir: `export DEV_PROJECT_DIR=~/dev/other-project`

---

## The Mental Model

```
SESSION  →  WINDOWS  →  PANES
(workspace)  (tabs)     (splits)
```

- **Session** — a named workspace. Persists even when you close the terminal.
- **Window** — a full-screen tab within a session.
- **Pane** — a split within a window.

---

## Prefix Key

**All tmux commands start with: `Ctrl+Space`**

Press and release `Ctrl+Space`, then press the command key.

---

## Sessions

| Key / Command | Action |
|---------------|--------|
| `tmux new -s name` | New named session |
| `tmux attach -t name` | Attach to session |
| `tmux ls` | List sessions |
| `Ctrl+Space d` | Detach (session keeps running) |
| `Ctrl+Space $` | Rename current session |
| `Ctrl+Space s` | Interactive session switcher |

---

## Windows (tabs)

| Key | Action |
|-----|--------|
| `Ctrl+Space c` | New window (opens in current dir) |
| `Ctrl+Space ,` | Rename window |
| `Ctrl+Space n` | Next window |
| `Ctrl+Space p` | Previous window |
| `Ctrl+Space 1-9` | Jump to window by number |
| `Ctrl+Space w` | Interactive window list |
| `Ctrl+Space &` | Kill window |

---

## Panes (splits)

| Key | Action |
|-----|--------|
| `Ctrl+Space \|` | Split vertical (side by side) |
| `Ctrl+Space -` | Split horizontal (top / bottom) |
| `Ctrl+Space h` | Move to pane left |
| `Ctrl+Space j` | Move to pane down |
| `Ctrl+Space k` | Move to pane up |
| `Ctrl+Space l` | Move to pane right |
| `Ctrl+Space z` | Zoom pane (toggle fullscreen) |
| `Ctrl+Space x` | Kill pane |
| `Ctrl+Space H` | Resize pane left |
| `Ctrl+Space J` | Resize pane down |
| `Ctrl+Space K` | Resize pane up |
| `Ctrl+Space L` | Resize pane right |
| `Ctrl+Space {` | Swap pane left |
| `Ctrl+Space }` | Swap pane right |

---

## Scrolling & Copy Mode

| Key | Action |
|-----|--------|
| `Ctrl+Space [` | Enter scroll/copy mode |
| `q` | Exit copy mode |
| Arrow keys / `j k` | Scroll line by line |
| `Ctrl+d / Ctrl+u` | Scroll half page |
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next search match |

---

## Misc

| Key | Action |
|-----|--------|
| `Ctrl+Space r` | Reload `tmux.conf` |
| `Ctrl+Space ?` | Show all keybindings |
| `Ctrl+Space t` | Show clock |

---

## Your Default Session Layout

When you run `dev up`, both windows get the same 3-pane layout:

```
┌─────────────────────┬──────────────┐
│                     │              │
│   main (pane 0)     │  side (pane 1) │
│   nvim / editing    │  terminal    │
│   70% width         │  cheatsheets │
│                     │  30% width   │
├─────────────────────┴──────────────┤
│   bottom (pane 2) — claude/cortex  │
│   25% height                       │
└────────────────────────────────────┘

Session: dev
├── Window 1 "dev"   → container shell (pane 0 auto-execs docker into container)
└── Window 2 "host"  → host machine shell
```

Switch windows: `Ctrl+Space 1` / `Ctrl+Space 2`

**Focus / zoom any pane: `Ctrl+Space z` — press again to restore**

**Typical workflow:**
1. `dev up` → lands in container main pane
2. `v` → open neovim (or work directly in main pane)
3. `Ctrl+Space l` → move to side pane for terminal / run `dev help tmux` for cheatsheet
4. `Ctrl+Space j` → move to bottom pane, run `claude` or `cortex`
5. `Ctrl+Space z` on any pane → zoom it to fullscreen to focus
6. `Ctrl+Space 2` → switch to host window if needed
7. `Ctrl+Space d` → detach (everything keeps running)
8. `dev up` → reattach later

---

## Neovim Window Navigation (for reference)

Since you might split both tmux panes and Neovim windows, here's the Neovim side for reference:

| Key | Action |
|-----|--------|
| `Space h/j/k/l` | Move between Neovim windows |
| `Space v` | Split vertical |
| `Space s` | Split horizontal |
| `Space z` | Zoom window |
| `Space q` | Close window |

---

## How to Get Claude to Review Your tmux Usage

tmux can log everything in a pane to a file using `pipe-pane`:

```bash
# Start logging current pane to a file
Ctrl+Space :pipe-pane -o "cat >> ~/tmux-session.log"

# Work normally for a while...

# Stop logging
Ctrl+Space :pipe-pane
```

Then paste the contents of `~/tmux-session.log` into a Claude conversation
and ask: *"Based on these terminal commands, what tmux or shell shortcuts
would most improve my workflow?"*

The more you log, the better the suggestions — Claude can spot patterns like
repeatedly switching panes the slow way, or commands you run so often they
deserve an alias.

---

## Most Important Things to Learn First

In rough order of payoff:

1. `Ctrl+Space d` — detach and reattach. This is the killer feature.
2. `Ctrl+Space c` / number keys — window management.
3. `Ctrl+Space |` and `-` — splits.
4. `Ctrl+Space z` — zoom. You'll use this constantly.
5. `Ctrl+Space [` — scroll mode. Essential for reading output.
