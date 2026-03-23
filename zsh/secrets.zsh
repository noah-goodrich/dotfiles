# Load API keys from macOS Keychain (silent fail if not on macOS or key not stored)
if [[ "$OSTYPE" == darwin* ]]; then
  export ANTHROPIC_API_KEY=$(security find-generic-password -s "ANTHROPIC_API_KEY" -a "$USER" -w 2>/dev/null)
  export GOOGLE_API_KEY=$(security find-generic-password -s "GOOGLE_API_KEY" -a "$USER" -w 2>/dev/null)
fi
