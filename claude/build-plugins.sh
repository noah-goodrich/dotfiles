#!/usr/bin/env bash
# =============================================================================
# Build .plugin files from source directories
# Produces installable .plugin files in claude/dist/
# Automatically increments the patch version in plugin.json on each build so
# Claude desktop recognises the plugin as updated and allows reinstall.
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
    plugin_json="$plugin_dir/.claude-plugin/plugin.json"

    # Verify it's a valid plugin
    if [ ! -f "$plugin_json" ]; then
        continue
    fi

    # Bump patch version (e.g. 0.1.0 → 0.1.1) before packaging
    current_version=$(grep '"version"' "$plugin_json" | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/')
    patch=$(echo "$current_version" | cut -d. -f3)
    new_patch=$((patch + 1))
    new_version=$(echo "$current_version" | sed "s/\.[0-9]*$/.${new_patch}/")
    sed -i.bak "s/\"version\": \"$current_version\"/\"version\": \"$new_version\"/" "$plugin_json"
    rm -f "$plugin_json.bak"
    info "Packaging $plugin_name  ($current_version → $new_version)..."

    # Build to /tmp first, then copy (avoids issues with some mounted filesystems).
    # COPYFILE_DISABLE=1 prevents macOS zip from adding __MACOSX/ resource fork
    # entries, which cause Cowork's plugin parser to reject the upload.
    (cd "$plugin_dir" && COPYFILE_DISABLE=1 zip -r "/tmp/$plugin_name.plugin" . \
        -x "*.DS_Store" -x "__MACOSX/*" -x "*/._*" > /dev/null)
    cp "/tmp/$plugin_name.plugin" "$DIST_DIR/$plugin_name.plugin"
    rm "/tmp/$plugin_name.plugin"
    info "  → dist/$plugin_name.plugin"
done

echo ""
info "Done. Install .plugin files via Cowork UI (drag or 'Copy to your skills')."
ls -lh "$DIST_DIR"/*.plugin 2>/dev/null
