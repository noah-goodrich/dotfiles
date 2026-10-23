# Cortex Code CLI Rules

## Shell Commands
- Run plain commands. Single pipes, `;` chains and a leading `VAR=x` (as in `LC_ALL=C sort | uniq`) are matched per subcommand and need no `bash -c` wrapper. `&&` and `||` chains are not yet measured.
- Use `git -C /path` (or a `run-in /path cmd` helper if installed) instead of `cd /path && cmd`.
- Prefer the Read and Grep tools over `cat`, `grep` and `find` when available.
- These plain shapes get prompted, or flatly denied in subagents: a loop using variables, nested `$(...)`, and a heredoc piped into an interpreter. Use the Read/Grep tools, separate plain calls or a named command instead. Use `bash -c` only for a lone loop or conditional that nothing else can express.
- A script mixing a loop, `$(...)` or variables with brace or awk-dollar text fails both plain and wrapped: split it into separate plain calls.
- If a command is denied by a safety check, restructure it into separate plain calls or use a tool. Never evade the check by respelling a word or obfuscating the target.
- Genuine deletions use literal paths, never variable targets, so the check can judge them.
- Put long data heredocs (code, docs) in a file with the Write tool, then run a short command on that file. Do not write throwaway executable scripts for logic a plain call can express.
- Always use absolute paths, never `~`.

## Links
- Write every PR, issue and Jira reference as a markdown link with the full URL, never bare: `[PR #461](https://github.com/owner/repo/pull/461)`, `[#449](https://github.com/owner/repo/issues/449)`. The terminal turns these into clickable links; a bare `#461` or `ABC-123` is not clickable. Do this in prose, lists and tables, but not inside fenced code blocks.
- When a reference does not name its repository, take owner/repo from `git remote get-url origin` (check once per session).
- Jira keys (`ABC-123`): run `printenv JIRA_URL` once per session. If it prints a site URL, write `[ABC-123](<JIRA_URL>/browse/ABC-123)`. If it prints nothing, leave the key plain; never guess a site.

## Tool Preference Hierarchy
When investigating Snowflake objects, prefer sources in this order:
1. **Local files first** — dbt YAML schemas (column descriptions, types, tests, FK relationships),
   CLAUDE.md files in project directories, ETL source code. Zero latency, zero cost.
2. **SHOW / DESCRIBE** — `SHOW TABLES IN SCHEMA`, `DESCRIBE TABLE`, `SHOW VIEWS`. Fast, no
   ACCOUNT_USAGE overhead.
3. **INFORMATION_SCHEMA** — Fast but scoped to one database. Use when you know the database.
4. **`cortex search object`** — Good for broad discovery across the account.
5. **ACCOUNT_USAGE views** — Last resort. Always add tight date filters and LIMIT clauses.
   These views routinely timeout on large accounts.

## ACCOUNT_USAGE Timeout Mitigation
- Always filter on a date column (e.g., `START_TIME >= DATEADD('month', -1, CURRENT_TIMESTAMP())`)
- Always include `LIMIT 50-100`
- Filter on `DATABASE_NAME` or `SCHEMA_NAME` when possible rather than `LIKE` on `QUERY_TEXT`
- If a query times out, narrow the date range or switch to INFORMATION_SCHEMA/SHOW

## Snowflake Connection
- Respect the user-set active connection. Do not switch connections without asking.
- Use `cortex connections list` to see available connections if needed.

## Local Metadata Strategy
- Before querying Snowflake for column info, check for dbt YAML schemas locally — they already
  contain column names, types, descriptions, and test definitions.
- Check for CLAUDE.md files in relevant project directories for pre-built domain context.
- dbt `target/manifest.json` and `target/catalog.json` are rich metadata caches when present.

## SQL Style in Cortex Code
- Same as Code Style in CLAUDE.md: uppercase keywords, lowercase identifiers, CTEs over subqueries.
- When writing exploratory queries, always include a LIMIT unless the user asks for full results.
