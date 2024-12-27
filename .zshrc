## Aliases
alias l="ls -Glah"
alias c="clear"

alias gpl="git pull"
alias gps="git push"
alias gco="git checkout"
alias gci="git commit"
alias gst="git status"

alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code -r"

alias pip="pip3"
alias python="python3"

# Docker aliases
alias dc="docker-compose"
alias dips="docker ps -q | xargs -n 1 docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
# shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

source $(brew --prefix nvm)/nvm.sh
export PATH="/opt/homebrew/opt/mariadb@10.11/bin:$PATH"

export LOCALSTACK_AUTH_TOKEN="ls-tAXe5996-XoXE-KElE-HOvu-7943WUTU0267"



