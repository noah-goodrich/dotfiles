#!/usr/bin/env bash
# =============================================================================
# Build project files for claude.ai from skill sources
#
# Produces TWO outputs:
#   1. dist/writing-rules.md   — paste into Project custom instructions
#   2. dist/project-context.md — upload as Project knowledge file
#
# The writing rules are generated from skill source files (voice, ai-scoring,
# linkedin, snowflake-article, token-cost). The project context is copied
# from claude/project/ and contains series state, visual style, etc.
#
# Usage: ./build-project.sh [project-context-file]
#   Default: claude/project/snowflake-builders-blog.md
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"
DIST_DIR="$SCRIPT_DIR/dist"
PROJECT_FILE="${1:-$SCRIPT_DIR/project/snowflake-builders-blog.md}"

GREEN='\033[0;32m'
NC='\033[0m'
info() { echo -e "${GREEN}[build-project]${NC} $1"; }

mkdir -p "$DIST_DIR"

# =========================================================================
# Part 1: Writing Rules (for Project instructions field)
# =========================================================================
RULES="/tmp/writing-rules.md"

cat > "$RULES" << 'HEADER'
# Writing Rules

Generated from skill sources in ~/.config/dotfiles/claude/plugins/
Edit the source files, not this document. Rebuild with: claude/build-project.sh

## Voice Rules (noah-voice)

HEADER

# Voice rules
if [ -f "$PLUGINS_DIR/noah-writing-voice/skills/noah-voice/references/voice-rules.md" ]; then
    # Skip the "# Noah Goodrich Voice Rules" title line and blank line
    tail -n +3 "$PLUGINS_DIR/noah-writing-voice/skills/noah-voice/references/voice-rules.md" >> "$RULES"
fi

cat >> "$RULES" << 'SECTION'

---

## AI Detection Scoring (ai-scoring)

Score all written output 0-100 before presenting. Flag specific AI tells and suggest rewrites.

### Detection Categories (deduct points from 100)

SECTION

# AI scoring categories
if [ -f "$PLUGINS_DIR/noah-writing-voice/skills/ai-scoring/SKILL.md" ]; then
    sed -n '/^### 1\./,/^## Output Format/p' "$PLUGINS_DIR/noah-writing-voice/skills/ai-scoring/SKILL.md" | head -n -1 >> "$RULES"
    echo "" >> "$RULES"
    sed -n '/^## Score Thresholds/,/^## Important/p' "$PLUGINS_DIR/noah-writing-voice/skills/ai-scoring/SKILL.md" | head -n -1 >> "$RULES"
fi

cat >> "$RULES" << 'SECTION'

---

## LinkedIn Post Rules (linkedin-post)

When creating LinkedIn posts:
- Hook must land before the "see more" fold (~210 characters, first 2-3 lines)
- NO external links in post body. Always "Link in comments." at the bottom
- Personal story > professional announcement for engagement
- End with a specific question people can answer from experience (not "what do you think?")
- 3-5 specific hashtags at end. Recurring: #SnowflakeDataSuperhero #DataEngineering #TheLongGame
- For article promotion: show enough to hook, cut before the payoff lands
- Always produce 2 variants with different strategic hooks

---

## Article Conventions (snowflake-article)

SECTION

# Snowflake article conventions
if [ -f "$PLUGINS_DIR/noah-content-tools/skills/snowflake-article/references/article-conventions.md" ]; then
    tail -n +3 "$PLUGINS_DIR/noah-content-tools/skills/snowflake-article/references/article-conventions.md" >> "$RULES"
fi

cat >> "$RULES" << 'SECTION'

---

## Token Cost

Append to every response: `Estimated tokens: ~Xk input, ~Y output. Cost: ~$Z.ZZ`
SECTION

cp "$RULES" "$DIST_DIR/writing-rules.md"
rm "$RULES"

RULES_CHARS=$(wc -c < "$DIST_DIR/writing-rules.md")
info "Generated: dist/writing-rules.md ($RULES_CHARS chars)"

# =========================================================================
# Part 2: Project Context (upload as knowledge file)
# =========================================================================
if [ -f "$PROJECT_FILE" ]; then
    cp "$PROJECT_FILE" "$DIST_DIR/project-context.md"
    CTX_CHARS=$(wc -c < "$DIST_DIR/project-context.md")
    info "Copied:    dist/project-context.md ($CTX_CHARS chars)"
else
    info "No project context file found at: $PROJECT_FILE"
fi

# =========================================================================
# Summary
# =========================================================================
echo ""
info "For your claude.ai Project:"
info "  1. Paste dist/writing-rules.md into Project custom instructions"
info "  2. Upload dist/project-context.md as a Project knowledge file"
info ""
info "Done."
