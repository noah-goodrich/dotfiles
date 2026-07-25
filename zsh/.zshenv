# Sourced by EVERY zsh invocation — interactive, non-interactive, login, and
# non-login (unlike .zshrc, which only runs for interactive shells). Keep this
# file cheap and side-effect-free: it also runs for every hook, subagent, and
# tool-invoked shell.
#
# Purpose: make dotfiles-shipped scripts (zsh/bin/) resolve even from
# non-interactive shells (e.g. `zsh -c ...`), which never source .zshrc.
export PATH="$HOME/.config/dotfiles/zsh/bin:$PATH"

export NODE_EXTRA_CA_CERTS=/etc/ssl/cert.pem
