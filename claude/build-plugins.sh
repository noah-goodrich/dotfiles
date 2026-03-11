#!/usr/bin/env bash
# =============================================================================
# Build .plugin files from source directories
# Produces installable .plugin files in claude/dist/
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"
DIST_DIR="$SCRIPT_DIR/dist"

GREEN='\033[0;32m'
NC='\033[0m'
info() { echo -e "${GREEN}[build]${NC} $1"; }

mkdir -p "$DIST_DIR"

for plugin_dir in "$PLUGINS_DIR"/*/; do
    plugin_name=$(basename "$plugin_dir")

    # Verify it's a valid plugin
    if [ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
        continue
    fi

    info "Packaging $plugin_name..."
    # Build to /tmp first, then copy (avoids issues with some mounted filesystems)
    (cd "$plugin_dir" && zip -r "/tmp/$plugin_name.plugin" . -x "*.DS_Store" > /dev/null)
    cp "/tmp/$plugin_name.plugin" "$DIST_DIR/$plugin_name.plugin"
    rm "/tmp/$plugin_name.plugin"
    info "  → dist/$plugin_name.plugin"
done

echo ""
info "Done. Install .plugin files via Cowork UI (drag or 'Copy to your skills')."
ls -lh "$DIST_DIR"/*.plugin 2>/dev/null
