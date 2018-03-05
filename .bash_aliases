alias l="ls -Glah"
alias c="clear"

alias gpl="git pl"
alias gps="git ps"
alias gco="git co"
alias gci="git ci"
alias gst="git st"

#alias bx="bundle exec"
#alias xrails="bundle exec rails"

#alias retl="/home/gmoney/dev/etl/bin/util/build_and_run.sh"

# Docker aliases
alias dc="cd ~/dev; docker-compose"
alias dips="docker ps -q | xargs -n 1 docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'"
