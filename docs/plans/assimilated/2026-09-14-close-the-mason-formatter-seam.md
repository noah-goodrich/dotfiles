# Project Plan: dotfiles — Increment 1, Close the Mason/Formatter Seam
*Established: 2026-09-14*
*Shipped: 2026-09-15 — PR [#16](https://github.com/noah-goodrich/dotfiles/pull/16) merged to main*

## Objective

Fix the two measured nvim dependency failures — the Mason installer that retried a permanently-failing install on
every launch for weeks, and the formatters declared but never installed that failed silently — and give the config a
single explicit list of required binaries that reports missing tools loudly. Dependency-management architecture
(Brewfile, `dotfiles doctor`, CI) is deliberately deferred to increments 2 and 3.

## Acceptance Criteria

- [x] Python formatting uses `ruff`; `black` appears nowhere in the nvim config
  - Verify: `grep -rn "black" /Users/noah/.config/dotfiles/nvim/` returns nothing
- [x] Missing formatters fail loudly — `notify_on_error` is enabled
  - Verify: `grep -n "notify_on_error" /Users/noah/.config/dotfiles/nvim/init.lua` shows `= true`
- [x] `sqls` and `delve` are gone, and a fresh nvim launch adds no new Go-toolchain install failure
  - Verify: note the current line count of `~/.local/state/nvim/mason.log`, launch nvim once, then confirm no new
    `Could not find executable "go"` lines were appended
- [x] A custom health check declares every required external binary and reports each as OK or ERROR
  - Verify: `nvim --headless "+checkhealth user" +qa` — every required binary listed, missing ones reported via
    `vim.health.error()`, not silently skipped
- [x] `install.sh` provisions every binary the nvim config declares, including `ruff` and `sqlfluff`
  - Verify: after `./install.sh`, `command -v ruff sqlfluff rg fd jq gh pipx` resolves all seven
- [x] Regression: nothing else breaks
  - Verify: `shellcheck install.sh` shows no new warnings; `nvim --headless +qa` exits 0; existing symlinks in
    `$HOME` still resolve to the repo

## Scope Boundaries

- NOT building: a Brewfile or any package manifest — that is increment 2
- NOT building: a `dotfiles doctor` unified entrypoint — increment 2
- NOT building: CI on either platform, required or advisory — increment 3
- NOT building: execution-based or AST-based dependency extraction — rejected by two blind reviews; the health
  check's binary list is hand-maintained on purpose, and is documented as such
- NOT building: unrelated kickstart cleanups (typescript/tsx/javascript treesitter parsers, `c`/`cpp` boilerplate)
  — real, but they belong in their own PR so this diff stays about dependencies
- If done early: Ship, don't expand.

## Ship Definition

Amend PR [#16](https://github.com/noah-goodrich/dotfiles/pull/16) (`fix/nvim-mason-go-seam`) rather than opening a
new one — it already carries the `sqls`/`delve` removal and the missing-tool additions. Add the `ruff` swap,
`notify_on_error = true`, `sqlfluff` provisioning, and `health.lua`. PR body updated to describe the full increment.
Merged to `main`. Manual smoke test: launch nvim, open a `.py` file, save it, confirm `ruff` formats it and that
no Mason errors appear.

## Timeline

Target: this session
Estimated effort: 1 session, ~1–2 hours. Six criteria, all small and local; the only real unknown is `ruff`
formatting output differing from `black` on existing Python files.

## Risks

- **`ruff format` is black-compatible but not byte-identical.** The first save on an existing Python file may
  produce reformatting churn. Expected, not a defect — worth knowing before it surprises you in a diff.
- **The health check's binary list is hand-maintained.** It can drift from the config it describes. This is the
  accepted trade-off after two blind reviews rejected derived extraction; increments 2 and 3 exist to add a
  forcing function. Documented in the file itself so the next reader knows it is deliberate.
- **The `mason.log` criterion needs a clean baseline.** Capture the line count before relaunching nvim, or the
  check is meaningless.
- **Unrelated hazard, not part of this plan:** some machine-local tooling sits untracked in the working directory of
  this public repo. A single `git add -A` would publish it. Handled separately by gitignoring those paths.

## Additional Work Shipped

Beyond the six criteria, PR [#17](https://github.com/noah-goodrich/dotfiles/pull/17) resolved the hazard named in
Risks above: three machine-local paths sitting untracked in this public repo are now gitignored, so a stray
`git add -A` can no longer publish them.

## Verification Record

Criteria were verified on 2026-09-15, after `install.sh` was run for the first time since the merge:

- `sqlfluff`, `rg`, and `fd` were absent until that run and were provisioned by it; all seven binaries now resolve.
- `checkhealth user` reports 8 OK / 0 ERROR. `stylua` resolves via the Mason path, not the shell `PATH`.
- `mason.log` held steady at 576 lines across a fresh launch; the last Go-toolchain failure is dated Sep 14 11:27:51,
  before the fix merged.
- Ship-definition smoke test passed: saving a `.py` file reformatted it via `ruff`.
