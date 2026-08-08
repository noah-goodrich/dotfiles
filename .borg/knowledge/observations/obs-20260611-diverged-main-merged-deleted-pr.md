---
id: obs-20260611-diverged-main-merged-deleted-pr
session_date: '2026-06-11'
project: dotfiles
tool: cursor
tags:
- git
- dotfiles
- diverged-branch
- pr-branch-tracking
category: gotcha
files_involved: []
confidence: 0.9
source_model: null
source_session: null
superseded_by: null
created_at: '2026-06-11 22:41:19.560997+00:00'
updated_at: '2026-07-24 03:52:21.933874+00:00'
---

# obs-20260611-diverged-main-merged-deleted-pr

## content

A local `main` branch can appear diverged from `origin/main` not because of real local work but because it was left pointing at a PR branch that was subsequently merged and deleted on origin. `git status` reports 'diverged' without indicating that the extra local commits are already in origin history.

## resolution

Confirm the 'extra' local commits are from the merged PR (check `git log --oneline origin/main..HEAD` vs the merged PR's commit list), then `git reset --hard origin/main`. Delete the dead PR tracking branch.
