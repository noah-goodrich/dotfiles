# secrets.zsh — Load API keys from macOS Keychain
#
# SECRET REGISTRY
# ----------------
# Each entry below documents a secret this dotfiles repo expects.
# On a fresh machine, create missing entries with:
#
#   security add-generic-password -s "<SERVICE>" -a "$USER" -w "<value>" -U
#
# Convention: SERVICE name = env var name (uppercase, underscores).
#
#   Env Var              Keychain Service       Purpose
#   -------------------  ---------------------  ----------------------------------------
#   ANTHROPIC_SDK_KEY    ANTHROPIC_SDK_KEY      Anthropic Python SDK (NOT Claude Code — it uses Max subscription)
#   GOOGLE_API_KEY       GOOGLE_API_KEY         Google API access
#   JIRA_API_TOKEN       JIRA_API_TOKEN         Atlassian Jira API token
#   JIRA_USERNAME        JIRA_USERNAME          Jira account email
#   JIRA_URL             JIRA_URL               Jira site URL (e.g. https://foo.atlassian.net)
#   NEXUS_HOST           NEXUS_HOST             Nexus host (e.g. nexus.example.com) — no-op if unset
#   NEXUS_USERNAME       NEXUS_USERNAME         Nexus artifact repo user token name
#   NEXUS_TOKEN          NEXUS_TOKEN            Nexus artifact repo token
#   SUPABASE_ACCESS_TOKEN SUPABASE_ACCESS_TOKEN Supabase CLI + management API token (for `supabase login`, project linking, db push)
#   REVEAL_SUPABASE_DB_PASSWORD REVEAL_SUPABASE_DB_PASSWORD  Postgres password for stillpoint-labs/reveal Supabase Cloud project
#   REVEAL_SUPABASE_ANON_KEY REVEAL_SUPABASE_ANON_KEY     Supabase anon/publishable key for reveal project (safe to expose client-side)
#   REVEAL_SUPABASE_SERVICE_ROLE_KEY REVEAL_SUPABASE_SERVICE_ROLE_KEY  Supabase service-role key for reveal project (bypasses RLS — used by worker + e2e admin client)
#   INGLE_SUPABASE_DB_PASSWORD  INGLE_SUPABASE_DB_PASSWORD   Postgres password for stillpoint-labs/ingle  Supabase Cloud project (set via dashboard if forgotten)
#   SNOWFLAKE_PAT              SNOWFLAKE_PAT                Snowflake programmatic access token for Cortex Code CLI in devcontainers
#   GH_TOKEN                   (via gh auth token)          GitHub CLI token for devcontainers — read directly from gh, no separate entry needed
#   FLY_API_TOKEN        FLY_API_TOKEN        Fly.io personal access token — covers all apps on the account
#   CLOUDFLARE_API_TOKEN CLOUDFLARE_API_TOKEN Cloudflare API token for DNS and Workers management (ingle)
#   CLOUDFLARE_ACCOUNT_ID CLOUDFLARE_ACCOUNT_ID Cloudflare account ID (ingle)
#   PORKBUN_API_KEY      PORKBUN_API_KEY      Porkbun domain registrar API key (ingle)
#   PORKBUN_SECRET_KEY   PORKBUN_SECRET_KEY   Porkbun domain registrar secret key (ingle)
#   PLAID_CLIENT_ID      PLAID_CLIENT_ID      Plaid client_id for the Troth team (shared across envs)
#   PLAID_SECRET         PLAID_SECRET         Plaid Sandbox secret for the Troth team (per-environment)
#   PLAID_TOKEN_ENCRYPTION_KEY PLAID_TOKEN_ENCRYPTION_KEY  Key that encrypts Plaid access tokens at rest (troth.plaid_items) — generate once, never rotate carelessly

if [[ "$OSTYPE" == darwin* ]]; then
    # Export env var from Keychain only if the entry exists.
    # Usage: _keychain_export VAR_NAME [KEYCHAIN_SERVICE]
    # KEYCHAIN_SERVICE defaults to VAR_NAME if omitted.
    _keychain_export() {
        local var_name="$1"
        local service="${2:-$1}"
        local val
        val=$(security find-generic-password -s "$service" -a "$USER" -w 2>/dev/null) || return 0
        export "$var_name=$val"
    }

    # BEGIN _keychain_export block
    _keychain_export ANTHROPIC_SDK_KEY
    _keychain_export GOOGLE_API_KEY
    _keychain_export JIRA_API_TOKEN
    _keychain_export JIRA_USERNAME
    _keychain_export JIRA_URL
    _keychain_export NEXUS_HOST
    _keychain_export NEXUS_USERNAME
    _keychain_export NEXUS_TOKEN
    _keychain_export SUPABASE_ACCESS_TOKEN
    _keychain_export REVEAL_SUPABASE_DB_PASSWORD
    _keychain_export REVEAL_SUPABASE_ANON_KEY
    _keychain_export REVEAL_SUPABASE_SERVICE_ROLE_KEY
    _keychain_export INGLE_SUPABASE_DB_PASSWORD
    _keychain_export SNOWFLAKE_PAT
    _keychain_export FLY_API_TOKEN
    _keychain_export CLOUDFLARE_API_TOKEN
    _keychain_export CLOUDFLARE_ACCOUNT_ID
    _keychain_export PORKBUN_API_KEY
    _keychain_export PORKBUN_SECRET_KEY
    _keychain_export PLAID_CLIENT_ID
    _keychain_export PLAID_SECRET
    _keychain_export PLAID_TOKEN_ENCRYPTION_KEY
    # END _keychain_export block

    unfunction _keychain_export

    # Plaid environment (non-secret). Sandbox until Production is ready.
    export PLAID_ENV="${PLAID_ENV:-sandbox}"

    # gh CLI manages its own keychain entry — read via gh rather than a separate entry.
    # gh auth token echoes an already-set GH_TOKEN, so a stale value would perpetuate itself
    # across re-sources; unset first so we always read the current keyring token (picks up scope
    # refreshes like `gh auth refresh -s workflow`).
    unset GH_TOKEN
    GH_TOKEN=$(gh auth token 2>/dev/null) || GH_TOKEN=""
    export GH_TOKEN

    if [[ -n "$NEXUS_HOST" && -n "$NEXUS_USERNAME" && -n "$NEXUS_TOKEN" ]]; then
        export PIP_INDEX_URL="https://${NEXUS_USERNAME}:${NEXUS_TOKEN}@${NEXUS_HOST}/repository/pypi-internal/simple"
        export PIP_EXTRA_INDEX_URL="https://pypi.org/simple/"
    fi
fi
