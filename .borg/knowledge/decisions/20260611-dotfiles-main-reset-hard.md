---
id: 20260611-dotfiles-main-reset-hard
date: '2026-06-11'
project: dotfiles
domain: infrastructure
tags:
- git
- dotfiles
- branch-hygiene
- diverged-branch
alternatives: []
applies_to: []
confidence: 0.9
status: active
superseded_by: null
cost_to_produce: null
source_tool: null
source_model: null
source_session: null
created_at: '2026-06-11 22:41:19.559160+00:00'
updated_at: '2026-06-11 22:41:19.559161+00:00'
---

# 20260611-dotfiles-main-reset-hard

## decision

Reset local `main` hard to `origin/main` to recover from a diverged state caused by a merged-and-deleted PR branch, rather than rebasing or merging.

## context

`main` had diverged because it was tracking a PR branch that had been merged and deleted on origin. The divergence was not meaningful work — it was stale history from the deleted branch.

## reasoning

Hard reset is safe when the diverged commits are confirmed to be from a merged PR (already in origin history) and not novel local work. Rebase would have been noisier and risked re-applying already-merged changes.
