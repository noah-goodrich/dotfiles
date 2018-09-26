alias l="ls -Glah"
alias c="clear"

alias gpl="git pl"
alias gps="git ps"
alias gco="git co"
alias gci="git ci"
alias gst="git st"

alias sxt="ssh -N -L 192.168.0.34:1433:exigo-usw2-mssql-e-0.ckt27h4brzc8.us-west-2.rds.amazonaws.com:1433 gt"

# Docker aliases
alias dc="export USER_ID=$(id -u); export GROUP_ID=$(id -g); docker-compose -f ~/dev/docker-compose.yml"
alias dips="docker ps -q | xargs -n 1 docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'"
