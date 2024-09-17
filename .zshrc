## Aliases
alias l="ls -Glah"
alias c="clear"

alias gpl="git pull"
alias gps="git push"
alias gco="git checkout"
alias gci="git commit"
alias gst="git status"

alias sxt="ssh -N -L 192.168.0.34:1433:exigo-usw2-mssql-e-0.ckt27h4brzc8.us-west-2.rds.amazonaws.com:1433 gt"

# Docker aliases
alias dc="docker-compose"
alias dips="docker ps -q | xargs -n 1 docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'"


PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git
