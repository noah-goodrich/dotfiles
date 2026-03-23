# Neovim Cheatsheet
## Noah's Config + Power Commands

---

## Your Custom Keymaps (from vimrc, translated to Neovim)

| Key | Action |
|-----|--------|
| `,` | Leader key |
| `jj` | Escape to normal mode |
| `Space` | Window prefix (replaces `Ctrl+w`) |
| `;` | Command mode (replaces `:`) |
| `,,` | Fuzzy-pick from open buffers (Telescope) |
| `,p` | Jump to previous window |
| `,o` | Toggle paste mode |
| `,e` | Toggle Neo-tree file explorer |
| `,w` | Strip trailing whitespace |
| `Enter` | Clear search highlight |
| `Ctrl+\` | Toggle floating terminal (toggleterm) |

### Window Navigation (your Space prefix)

| Key | Action |
|-----|--------|
| `Space h/j/k/l` | Move between windows |
| `Space v` | Split vertical |
| `Space s` | Split horizontal |
| `Space q` | Close window |
| `Space z` | Zoom window (toggle fullscreen) |
| `Space =` | Equalize window sizes |

---

## Power Commands — Motion & Editing

These are the ones that separate vim users from vim power users.

### Motions you're probably underusing

| Key | Action |
|-----|--------|
| `f<char>` | Jump forward to character on line |
| `F<char>` | Jump backward to character on line |
| `t<char>` | Jump to just before character |
| `;` | Repeat last f/t jump (conflicts with your `;` → `:` map — worth knowing) |
| `%` | Jump to matching bracket/paren/brace |
| `*` | Search for word under cursor (forward) |
| `#` | Search for word under cursor (backward) |
| `gg` / `G` | Top / bottom of file |
| `Ctrl+o` | Jump back in jump list |
| `Ctrl+i` | Jump forward in jump list |
| `'.` | Jump to last edit location |
| `gi` | Go back to last insert location and enter insert mode |

### Text objects — the most powerful vim concept

Format: `[operator][a/i][object]`
- `a` = "around" (includes delimiters)
- `i` = "inner" (excludes delimiters)

| Example | What it does |
|---------|-------------|
| `ciw` | Change inner word |
| `daw` | Delete around word (includes space) |
| `ci"` | Change inside quotes |
| `ca(` | Change around parentheses (includes parens) |
| `di{` | Delete inside curly braces |
| `yip` | Yank inner paragraph |
| `vis` | Select inner sentence |
| `=ip` | Re-indent inner paragraph |

### Operators you might not use enough

| Key | Action |
|-----|--------|
| `>>`/ `<<` | Indent / dedent line |
| `=` | Auto-indent (e.g. `=ip` re-indents paragraph) |
| `gU` | Uppercase (e.g. `gUiw` uppercases word) |
| `gu` | Lowercase |
| `g~` | Toggle case |
| `J` | Join line below to current |
| `gJ` | Join without adding space |

### Registers — cut/copy/paste done right

| Key | Action |
|-----|--------|
| `"ayy` | Yank line into register `a` |
| `"ap` | Paste from register `a` |
| `"+y` | Yank to system clipboard |
| `"+p` | Paste from system clipboard |
| `"0p` | Paste last yanked text (not deleted) |
| `Ctrl+r "` | Paste from default register (in insert mode) |
| `Ctrl+r +` | Paste from clipboard (in insert mode) |
| `:reg` | Show all register contents |

> **Why `"0p` matters:** When you `d` (delete) something, it goes into `"` and overwrites what you yanked. `"0` always holds your last explicit yank, unaffected by deletes.

### Macros

| Key | Action |
|-----|--------|
| `qa` | Start recording macro into register `a` |
| `q` | Stop recording |
| `@a` | Play macro `a` |
| `@@` | Replay last macro |
| `10@a` | Replay macro 10 times |

### Marks

| Key | Action |
|-----|--------|
| `ma` | Set mark `a` at cursor |
| `` `a `` | Jump to exact position of mark `a` |
| `'a` | Jump to line of mark `a` |
| `` `. `` | Jump to last edit |
| `` `< `` / `` `> `` | Jump to start/end of last visual selection |

---

## Buffers & Files

| Key / Command | Action |
|---------------|--------|
| `,,` | **Telescope buffer list** (fuzzy-pick any open file) |
| `,bn` / `,bp` | Next / previous buffer |
| `,bd` | Close (delete) buffer |
| `,bl` | Buffer list (same as `,,`) |
| `Ctrl+^` | Toggle between last two buffers (native) |
| `:e filename` | Open file |
| `:ls` | List open buffers (raw) |
| `:b <partial>` | Switch to buffer by partial name |
| `:w` | Save |
| `:wa` | Save all |
| `:wqa` | Save all and quit |

---

## Search & Replace

| Command | Action |
|---------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next / previous match |
| `*` | Search word under cursor |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace all with confirmation |
| `:s/old/new/g` | Replace in current line |
| `:'<,'>s/old/new/g` | Replace in visual selection |
| `:g/pattern/d` | Delete all lines matching pattern |
| `:v/pattern/d` | Delete all lines NOT matching pattern |

---

## Visual Mode

| Key | Action |
|-----|--------|
| `v` | Character visual mode |
| `V` | Line visual mode |
| `Ctrl+v` | Block visual mode |
| `gv` | Re-select last visual selection |
| `o` | Move to other end of selection |
| `I` | Insert at start of each line (block mode) |
| `A` | Append at end of each line (block mode) |

---

## Fugitive (Git)

`:Gwrite` still works. The old single-letter commands (`:Gstatus`, `:Gdiff`)
are soft-deprecated — the modern way is `:G` + any git command.

### Core workflow

| Command | Action | Old equivalent |
|---------|--------|----------------|
| `:G` | Open git status window | `:Gstatus` |
| `:Gwrite` | Stage current file (`git add %`) | same |
| `:Gread` | Revert file to last commit (`git checkout %`) | same |
| `:G commit` | Commit (opens message in split) | `:Gcommit` |
| `:G push` | Push | — |
| `:G pull` | Pull | — |
| `:G diff` | Diff working tree | `:Gdiff` |
| `:G log` | Log in buffer | `:Glog` |
| `:G blame` | Blame view | `:Gblame` |
| `:GMove path` | Rename/move file | `:Gmove` |
| `:GDelete` | Delete file and close buffer | `:Gdelete` |
| `:GBrowse` | Open file on GitHub | same |

### Inside the `:G` status window

| Key | Action |
|-----|--------|
| `s` | Stage file under cursor |
| `u` | Unstage file under cursor |
| `-` | Toggle stage/unstage |
| `U` | Unstage everything |
| `X` | Discard change under cursor |
| `cc` | Commit staged changes |
| `ca` | Amend last commit |
| `Enter` | Open file |
| `dd` | Open diff for file under cursor |
| `p` | Stage/unstage hunk (partial staging) |
| `=` | Toggle inline diff |
| `gq` | Close window |

### Diff / merge conflict resolution

| Command / Key | Action |
|---------------|--------|
| `:G diff` | Diff working vs staged |
| `]c` / `[c` | Next / previous change in diff |
| `:diffget //2` | Take change from left (target branch) |
| `:diffget //3` | Take change from right (merge branch) |
| `:G mergetool` | Open 3-way merge for all conflicts |

### Browsing history

| Command | Action |
|---------|--------|
| `:G log %` | Log for current file |
| `:G log` | Full repo log |
| `Enter` on a commit | Open that commit |
| `ri` on a commit (in log) | Interactive rebase from that commit |

---

## Monitoring Your Own Neovim Usage

### See what keymaps you actually have

```vim
:verbose map          " all normal mode maps + where they're defined
:verbose imap         " insert mode maps
:verbose nmap ,       " all maps starting with your leader
```

### Log a session for Claude to review

Add this to your `init.lua` temporarily:

```lua
-- Log all normal mode keystrokes to a file
-- Remove when done collecting data
local log = io.open(vim.fn.expand("~/.local/share/nvim/keylog.txt"), "a")
vim.on_key(function(key)
  if vim.api.nvim_get_mode().mode == "n" then
    log:write(key)
    log:flush()
  end
end)
```

Work normally for a session, then paste `~/.local/share/nvim/keylog.txt`
into Claude and ask: *"What patterns do you see that suggest better shortcuts
I could be using?"*

### The faster way: just ask

After a session, note the friction moments and ask Claude directly:
- *"I keep using `gg/pattern<Enter>` to find something at the top of the file — is there a faster way?"*
- *"I navigate between files by opening NERDTree every time — what should I use instead?"*
- *"I do a lot of `:s/old/new/gc` — how do I make that faster?"*

Targeted questions beat log analysis every time.

---

## Toggleterm (Floating Terminal)

| Key | Action |
|-----|--------|
| `Ctrl+\` | Open / close floating terminal |
| `Ctrl+\` (inside terminal) | Close it (works in terminal mode too) |
| `2<C-\>` | Open terminal #2 (keep claude in #1, shell in #2, etc.) |

> Run `claude`, `cortex`, `git`, or any CLI from here without leaving Neovim.

---

## LSP & Formatting

Your config auto-installs these via Mason:

| Language | LSP Server | Formatter |
|----------|-----------|-----------|
| Lua | `lua_ls` | `stylua` |
| Python | `pyright` | `black` |
| SQL | `sqls` | `sqlfluff` |

Useful LSP keymaps (from Kickstart defaults):

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>ds` | Document symbols (Telescope) |

---

## Fugitive Leader Shortcuts

| Key | Action |
|-----|--------|
| `,gs` | Git status (`:G` window) |
| `,gb` | Git blame |
| `,gd` | Git diff split |
| `,gl` | Git log (oneline) |

---

## Most Important Things to Learn First

In rough order of payoff for your workflow:

1. **Text objects** — `ciw`, `ci"`, `ca(` etc. Most impactful thing to internalize.
2. **`*`** — search word under cursor. Use it constantly.
3. **`Ctrl+o` / `Ctrl+i`** — jump list navigation. Replaces a lot of `,,` usage.
4. **`"0p`** — paste last yank, unaffected by deletes.
5. **Macros** — `qa` ... `q` ... `@a`. Automating repetitive edits.
6. **`:G` status window** — `s`, `cc`, `p` for partial staging. Full git workflow without leaving Neovim.
