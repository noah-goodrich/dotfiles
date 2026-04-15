#!/usr/bin/env bash
# =============================================================================
# Dotfiles Install Script
# Safe to re-run — backs up existing files before symlinking
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[dotfiles]${NC} $1"; }
warn()    { echo -e "${YELLOW}[dotfiles]${NC} $1"; }
error()   { echo -e "${RED}[dotfiles]${NC} $1"; }

# -----------------------------------------------------------------------------
# Symlink helper — backs up existing file/dir before linking
# Usage: link <source> <target>
# -----------------------------------------------------------------------------
link() {
    local src="$1"
    local dst="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # If target already exists and is not already our symlink
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        warn "Backing up existing $dst → $BACKUP_DIR/"
        mv "$dst" "$BACKUP_DIR/"
    fi

    # Remove stale symlink
    [ -L "$dst" ] && rm "$dst"

    # Use a path relative to the symlink's directory so the link resolves
    # correctly even when the home directory differs (e.g. inside containers).
    local rel_src
    rel_src=$(python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], os.path.dirname(sys.argv[2])))" "$src" "$dst" 2>/dev/null) || rel_src="$src"
    ln -sf "$rel_src" "$dst"
    info "Linked $dst → $rel_src"
}

# -----------------------------------------------------------------------------
# Install dependencies
# Checks for required tools and installs what's missing
# -----------------------------------------------------------------------------
install_deps() {
    info "Checking dependencies..."

    # tmux
    if ! command -v tmux &>/dev/null; then
        warn "tmux not found — installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install tmux
        else
            sudo apt-get install -y tmux
        fi
    fi

    # Zsh
    if ! command -v zsh &>/dev/null; then
        warn "zsh not found — installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install zsh
        else
            sudo apt-get install -y zsh
        fi
    fi

    # Powerlevel10k
    if [ ! -d "$HOME/.config/zsh/powerlevel10k" ]; then
        info "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$HOME/.config/zsh/powerlevel10k"
    fi

    # zsh-autosuggestions
    if [ ! -d "$HOME/.config/zsh/zsh-autosuggestions" ]; then
        info "Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.config/zsh/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$HOME/.config/zsh/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$HOME/.config/zsh/zsh-syntax-highlighting"
    fi
}

# -----------------------------------------------------------------------------
# Merge Claude Code settings.json (non-destructive)
# Merges dotfiles base config into existing ~/.claude/settings.json.
# Preserves hooks, plugins, and permissions added by other tools (e.g. borg).
# -----------------------------------------------------------------------------
merge_claude_settings() {
    local template="$DOTFILES_DIR/claude/code/settings.json"
    local target="$HOME/.claude/settings.json"
    local plugins_path="$HOME/dev/claude-plugins"

    if ! command -v jq &>/dev/null; then
        warn "jq not found — cannot merge settings.json"
        if [ ! -f "$target" ]; then
            warn "Copying template as fallback (install jq and re-run to merge properly)"
            cp "$template" "$target"
        fi
        return
    fi

    if [ ! -f "$target" ]; then
        # Fresh install: copy template + inject marketplace path
        info "Creating ~/.claude/settings.json from template..."
        jq --arg p "$plugins_path" \
            '.extraKnownMarketplaces["noah-local"] = {"source":{"source":"directory","path":$p}}' \
            "$template" > "$target"
        return
    fi

    # Existing file: merge dotfiles settings without clobbering
    info "Merging dotfiles hooks into existing settings.json..."
    local tmp="$target.tmp.$$"

    # Strategy: use template as base for permissions/model, but UNION hooks
    # from both files so nothing gets lost. Preserve existing plugins/marketplaces.
    jq -s --arg p "$plugins_path" '
        .[0] as $existing | .[1] as $template |

        # Start with existing file (preserves everything)
        $existing |

        # Update permissions from template (dotfiles is authoritative for these)
        .permissions = $template.permissions |

        # Update model from template
        .model = $template.model |

        # Merge hooks: for each event in template, add any hooks not already present
        .hooks = (
            ($existing.hooks // {}) as $eh |
            ($template.hooks // {}) as $th |
            ($eh | keys) + ($th | keys) | unique | map(
                . as $evt |
                ($eh[$evt] // []) as $existing_entries |
                ($th[$evt] // []) as $template_entries |
                # Collect all hook commands already in existing
                ($existing_entries | [.[].hooks[]?.command]) as $existing_cmds |
                # Add template entries whose commands are not already present
                ($template_entries | map(
                    select(.hooks | map(.command) | all(. as $c | $existing_cmds | index($c) | not))
                )) as $new_entries |
                {key: $evt, value: ($existing_entries + $new_entries)}
            ) | from_entries
        ) |

        # Inject local plugin marketplace path
        .extraKnownMarketplaces["noah-local"] = {"source":{"source":"directory","path":$p}}
    ' "$target" "$template" > "$tmp" && mv "$tmp" "$target"
    info "  settings.json merged (existing hooks preserved)"
}

# -----------------------------------------------------------------------------
# Link all dotfiles
# -----------------------------------------------------------------------------
link_dotfiles() {
    info "Linking dotfiles..."

    # tmux
    link "$DOTFILES_DIR/tmux/tmux.conf"   "$HOME/.config/tmux/tmux.conf"

    # zsh
    link "$DOTFILES_DIR/zsh/.zshrc"       "$HOME/.zshrc"
    # p10k config (generated by `p10k configure`, stored in repo)
    [ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ] && link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

    # git
    link "$DOTFILES_DIR/git/config"       "$HOME/.gitconfig"
    link "$DOTFILES_DIR/git/ignore"       "$HOME/.config/git/ignore"

    # neovim
    link "$DOTFILES_DIR/nvim"             "$HOME/.config/nvim"

    # ghostty
    link "$DOTFILES_DIR/ghostty"          "$HOME/.config/ghostty"

    # Claude Code — link config + hooks into ~/.claude/
    # (Don't link the whole directory; ~/.claude/ also holds machine-local
    # state like handovers, session logs, and auto-memory that shouldn't
    # be in the repo.)
    mkdir -p "$HOME/.claude/hooks"
    link "$DOTFILES_DIR/claude/code/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"

    # settings.json: merge dotfiles base into existing file (preserves borg
    # hooks, plugins, etc. added by other installers). Never overwrite.
    merge_claude_settings
    # Copy hooks (not symlink) so they work inside devcontainers where
    # bind-mounted ~/.claude can't follow host-absolute symlink targets.
    for hook in "$DOTFILES_DIR/claude/code/hooks/"*; do
        [ -f "$hook" ] || continue
        local name
        name="$(basename "$hook")"
        rm -f "$HOME/.claude/hooks/$name"
        cp "$hook" "$HOME/.claude/hooks/$name"
        chmod +x "$HOME/.claude/hooks/$name"
    done

    # Slash commands — copy (not symlink) for devcontainer compatibility
    mkdir -p "$HOME/.claude/commands"
    for cmd in "$DOTFILES_DIR/claude/code/commands/"*.md; do
        [ -f "$cmd" ] || continue
        local cname
        cname="$(basename "$cmd")"
        rm -f "$HOME/.claude/commands/$cname"
        cp "$cmd" "$HOME/.claude/commands/$cname"
    done
}

# -----------------------------------------------------------------------------
# Build base devcontainer image (if Docker is available)
# This image is extended by every project's Dockerfile
# -----------------------------------------------------------------------------
build_base_devcontainer() {
    if ! command -v docker &>/dev/null; then
        warn "Docker not found — skipping base devcontainer image build"
        return
    fi

    # Ensure shared Docker network exists (used by all devcontainers)
    info "Ensuring devnet Docker network exists..."
    docker network inspect devnet >/dev/null 2>&1 || docker network create devnet

    local dockerfile="$DOTFILES_DIR/devcontainer/Dockerfile.base"
    if [ -f "$dockerfile" ]; then
        info "Building devcontainer-base:local image..."
        docker build -f "$dockerfile" -t devcontainer-base:local "$DOTFILES_DIR/devcontainer/" \
            && info "  → devcontainer-base:local built successfully" \
            || warn "  → devcontainer-base:local build failed (Docker may not be running)"
    else
        warn "devcontainer/Dockerfile.base not found, skipping base image build"
    fi
}

# -----------------------------------------------------------------------------
# Clone or update the claude-plugins repo
# Source: github.com/noah-goodrich/claude-plugins
# Cloned to: ~/dev/claude-plugins
# The noah-local marketplace points at this clone so Claude Code can install
# plugins without needing the plugin source in the dotfiles repo.
# -----------------------------------------------------------------------------
CLAUDE_PLUGINS_DIR="$HOME/dev/claude-plugins"
CLAUDE_PLUGINS_REPO="https://github.com/noah-goodrich/claude-plugins.git"

sync_claude_plugins() {
    if [ -d "$CLAUDE_PLUGINS_DIR/.git" ]; then
        info "Updating claude-plugins..."
        git -C "$CLAUDE_PLUGINS_DIR" pull --ff-only || warn "claude-plugins pull failed (non-fatal)"
    else
        info "Cloning claude-plugins..."
        git clone "$CLAUDE_PLUGINS_REPO" "$CLAUDE_PLUGINS_DIR" \
            || warn "claude-plugins clone failed (non-fatal)"
    fi
}

install_claude_plugins() {
    info "Installing Claude plugins and project files..."

    sync_claude_plugins

    # Build project instructions for claude.ai
    if chmod +x "$DOTFILES_DIR/claude/build-project.sh" 2>/dev/null; then
        bash "$DOTFILES_DIR/claude/build-project.sh"
    else
        warn "claude/build-project.sh not found, skipping project build"
    fi

    # Register the marketplace with the Claude Code CLI. Claude Code caches
    # marketplace state separately from settings.json, so we must use the CLI
    # to update it — writing to settings.json alone is not enough.
    if ! command -v claude >/dev/null 2>&1; then
        info "  claude CLI not found — install plugins later via: claude plugin install <name>@noah-local"
    elif [ -d "$CLAUDE_PLUGINS_DIR" ]; then
        # Re-register marketplace to pick up path changes (remove is a no-op if missing)
        claude plugin marketplace remove noah-local 2>/dev/null || true
        claude plugin marketplace add "$CLAUDE_PLUGINS_DIR" \
            && info "  noah-local marketplace → $CLAUDE_PLUGINS_DIR" \
            || warn "Failed to register noah-local marketplace (non-fatal)"

        for plugin_dir in "$CLAUDE_PLUGINS_DIR"/*/; do
            [ -d "$plugin_dir" ] || continue
            plugin_json="$plugin_dir/.claude-plugin/plugin.json"
            [ -f "$plugin_json" ] || continue
            plugin_name=$(basename "$plugin_dir")
            info "Installing plugin: $plugin_name"
            claude plugin install "${plugin_name}@noah-local" || warn "Failed to install $plugin_name (non-fatal)"
        done
    fi

    echo ""
    info "Claude artifacts built to: $DOTFILES_DIR/claude/dist/"
    info "  project-context  → upload as claude.ai Project knowledge file"
}

# -----------------------------------------------------------------------------
# Create ~/.gitconfig.local stub if missing
# This file holds machine-specific identity (user.email) and is gitignored —
# it is never committed to the dotfiles repo.
# -----------------------------------------------------------------------------
ensure_gitconfig_local() {
    local gitconfig_local="$HOME/.gitconfig.local"
    if [ ! -f "$gitconfig_local" ]; then
        cat > "$gitconfig_local" <<'EOF'
[user]
	# Set your email for this machine:
	email = your@email.com
EOF
        warn "Created ~/.gitconfig.local — set your email:"
        warn "  git config -f ~/.gitconfig.local user.email 'your@email.com'"
    fi
}

# -----------------------------------------------------------------------------
# Reload zshrc in all open tmux panes
# -----------------------------------------------------------------------------
reload_all_panes() {
    if ! command -v tmux &>/dev/null || ! tmux list-sessions &>/dev/null 2>&1; then
        info "No tmux session running — start a new shell to pick up changes"
        return
    fi

    local pane_ids
    pane_ids=$(tmux list-panes -a -F '#{pane_id}')
    local count=0
    while IFS= read -r pid; do
        [ -z "$pid" ] && continue
        tmux send-keys -t "$pid" " source ~/.zshrc" Enter
        count=$((count + 1))
    done <<< "$pane_ids"
    info "Reloaded ~/.zshrc in $count tmux pane(s)"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    info "Starting dotfiles installation from $DOTFILES_DIR"

    install_deps
    ensure_gitconfig_local
    link_dotfiles
    build_base_devcontainer
    install_claude_plugins
    reload_all_panes

    info "Done!"

    if [ -d "$BACKUP_DIR" ]; then
        warn "Backups saved to: $BACKUP_DIR"
    fi
}

main "$@"
