---
id: 20260611-archive-dead-branch-to-tag
date: '2026-06-11'
project: dotfiles
domain: infrastructure
tags:
- git
- branch-hygiene
- archival
- dead-code
alternatives: []
applies_to: []
confidence: 0.7
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: null
created_at: '2026-06-11 22:41:19.559584+00:00'
updated_at: '2026-06-11 22:41:19.559585+00:00'
---

# 20260611-archive-dead-branch-to-tag

## decision

Archive the `borg-compat` branch (3 unmerged commits, superseded by claude-plugins) to a `archive/borg-compat` tag before deleting the branch, rather than simply force-deleting.

## context

`borg-compat` had 3 unmerged commits / ~3269 lines that were superseded by the claude-plugins system and a dead `dev.sh`. Deleting without a tag would make the commits unreachable and eventually GC'd.

## reasoning

Tagging before deletion preserves the SHA history for forensic reference without cluttering the active branch list. Cost is near zero; benefit is recoverable history if the superseding system ever needs to reference the old approach.
