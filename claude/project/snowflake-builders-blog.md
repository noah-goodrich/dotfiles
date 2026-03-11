# Snowflake Builder's Blog — Project Context

This file contains project-specific context for Noah's Snowflake Builders Blog articles.
It is meant to be pasted into claude.ai Project instructions alongside the generated
writing-rules block from `build-project.sh`.

Edit the source skills in `claude/plugins/` for voice/writing rules.
Edit THIS file for project-specific context (article state, series info, tools).

---

## Series Architecture

### The Long Game
Leadership/stewardship series using parenting and mentorship metaphors.
Parts 1-3 published, Part 4 in draft (v3).
Mental model: CCC (Calm, Connect, Coach).

### WAF Series ("Five Pillars, One Foundation")
Technical deep-dives on Snowflake's Well-Architected Framework.
Overview in draft (~v6, ~2,400 words), pillar articles not yet drafted.
Entry point article: "Five Pillars, One Foundation."

### Connection
The Long Game provides the "why" (stewardship philosophy).
The WAF Series provides the "how" (practical frameworks).
CCC bridges both: Calm (understand before reacting), Connect (build relationships and context), Coach (guide others toward better decisions).

## snowfort
Open-source CLI tool that automates WAF assessments across five pillars: Security & Governance, Operational Excellence, Reliability, Performance, and Cost Optimization.

Structural metaphor: WAF = blueprint; snowfort = building inspector; the fort = the environment; engineers/AI agents = builders; Mom = architect/steward.

Competitive positioning (vs native WAF review, Ippon's WAFR Custom Lens, FinOps-only tools, custom scripts) is still being decided.

Separate quickstart guide planned but not yet written.

## Current Article State
- WAF Overview: ~v6, ~2,400 words. Placeholder links remain for snowfort repo and Noah's LinkedIn. LLM summary feature screenshot not yet available.
- snowfort CLI output still needs integration into WAF Overview (prefer code blocks over screenshots).
- Five planned pillar deep-dive articles not yet drafted.

## Visual Style (All Series)
- Playful, childlike, 3D animation (Pixar-adjacent)
- Recurring characters: Mom, Son, Robot, Baby
- Hexagonal elements, blue-white palette, snowy mountain backdrops
- WAF images can and do include characters
- Image generation via Gemini Gem system (modular template architecture, compositing characters/elements). Prompts must isolate individual elements, not describe full scenes.
- Five WAF pillar flags: plant in snow in a semi-circle behind the group (avoids Gemini's flag-sizing failures when characters hold them)
- Visual progression concept: blueprint/planning scene for Overview, construction stages per pillar, completed fort for final summary piece
- NEVER use the word "snowflake" in image generation prompts (models render literal snowflakes)

## Formatting Conventions
- Bold both CCC terms and five pillar names as visual landmarks
- Prefer code blocks over screenshots for snowfort CLI output (exception: snowfort TUI output can use screenshots)
- CTA sections are the one place bullet points are acceptable

## On-Request Tools
- Structural redundancy analysis: map repeated points, count them, propose consolidated structure. Not automatic; only when Noah asks.
- AI detection scoring and readiness assessments available on request.

## Key External References
- Sudhendu's Medium article
- Keith Belanger's CloverDX podcast ("Behind the Data," ~24:28 for "popcorn architecture" quote)
- Snowflake's WAF engineering blog
- Official pillar documentation links

## Workflow Notes
- Starting fresh chats for distinct tasks is the most effective token cost approach
- Handoff documents carry context across fresh sessions
- Specific, content-rich search terms (memorable phrases from actual drafts) outperform generic topic queries when searching conversation history
