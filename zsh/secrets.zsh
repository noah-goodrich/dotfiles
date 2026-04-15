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

    _keychain_export ANTHROPIC_SDK_KEY
    _keychain_export GOOGLE_API_KEY
    _keychain_export JIRA_API_TOKEN
    _keychain_export JIRA_USERNAME
    _keychain_export JIRA_URL
    _keychain_export NEXUS_HOST
    _keychain_export NEXUS_USERNAME
    _keychain_export NEXUS_TOKEN

    unfunction _keychain_export

    if [[ -n "$NEXUS_HOST" && -n "$NEXUS_USERNAME" && -n "$NEXUS_TOKEN" ]]; then
        export PIP_INDEX_URL="https://${NEXUS_USERNAME}:${NEXUS_TOKEN}@${NEXUS_HOST}/repository/pypi-internal/simple"
        export PIP_EXTRA_INDEX_URL="https://pypi.org/simple/"
    fi
fi
