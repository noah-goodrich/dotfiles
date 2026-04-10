# Cortex Code CLI Rules

All Bash Tool Rules from CLAUDE.md apply equally in Cortex Code sessions. Additionally:

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
