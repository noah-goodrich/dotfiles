#!/usr/bin/env zsh
# dev — multi-project devcontainer + tmux manager
#
# Usage:
#   cd ~/dev/my-project && dev up     # add project window to session
#   dev down                           # remove this project's window + containers
#   dev status                         # show all projects in session
#   dev help [tmux|nvim|git|keys]

set -e

# Ensure API keys are available for docker compose (don't rely on calling shell)
source "$HOME/.config/dotfiles/zsh/secrets.zsh"

SESSION="dev"
COMPOSE_FILE=".devcontainer/docker-compose.yml"
POSTGRES_COMPOSE="$HOME/.config/dotfiles/devcontainer/docker-compose.postgres.yml"

# Colors
GREEN='\033[0;32m'  YELLOW='\033[1;33m'  RED='\033[0;31m'  CYAN='\033[0;36m'  NC='\033[0m'
info()  { echo -e "${GREEN}▸${NC} $1"; }
warn()  { echo -e "${YELLOW}▸${NC} $1"; }
die()   { echo -e "${RED}▸ ERROR:${NC} $1" >&2; exit 1; }
dbg()   { echo -e "${CYAN}  [dbg]${NC} $1" >&2; }

# ── Helpers ──────────────────────────────────────────────────────────────────

get_project_name() {
    basename "$(pwd)"
}

get_project_container() {
    local dir="${1:-$(pwd)}"
    local name
    name=$(basename "$dir")
    # Find the app container by dev.role label; fall back to first container
    docker ps --filter "label=com.docker.compose.project=$name" \
              --filter "label=dev.role=app" \
              --format '{{.Names}}' 2>/dev/null | head -1 \
    || docker compose -p "$name" -f "$dir/$COMPOSE_FILE" ps --format '{{.Names}}' 2>/dev/null | head -1
}

get_service_name() {
    local dir="${1:-$(pwd)}"
    local name
    name=$(basename "$dir")
    docker ps --filter "label=com.docker.compose.project=$name" \
              --filter "label=dev.role=app" \
              --format '{{.Label "com.docker.compose.service"}}' 2>/dev/null | head -1
}

get_shell() {
    local c="$1"
    dbg "get_shell: probing shell in container '$c'"
    local s
    s=$(docker exec "$c" sh -c 'command -v zsh || command -v bash' 2>/dev/null) || s="/bin/sh"
    dbg "get_shell: found '$s'"
    echo "$s"
}

has_window() {
    tmux list-windows -t "$SESSION" -F '#W' 2>/dev/null | grep -qx "$1"
}

window_pane_count() {
    tmux list-panes -t "$SESSION:$1" 2>/dev/null | wc -l | tr -d ' '
}

# Count project windows (all windows except 'host')
project_window_count() {
    tmux list-windows -t "$SESSION" -F '#W' 2>/dev/null | grep -vcx 'host' | tr -d ' '
}

ensure_network() {
    if ! docker network inspect devnet &>/dev/null; then
        dbg "ensure_network: creating devnet"
        docker network create devnet
    fi
}

ensure_postgres() {
    ensure_network
    dbg "ensure_postgres: starting shared postgres"
    docker compose -f "$POSTGRES_COMPOSE" up -d
}

# ── Window Creation ──────────────────────────────────────────────────────────

create_3pane_window() {
    # $1 = window name, $2 = command to send to each pane (optional)
    local wname="$1" cmd="$2"
    dbg "create_3pane_window: '$wname'"

    local main
    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        # No session yet — create it with this window
        main=$(tmux new-session -d -s "$SESSION" -n "$wname" -PF '#{pane_id}')
    else
        main=$(tmux new-window -t "$SESSION" -n "$wname" -PF '#{pane_id}')
    fi

    # Split: bottom (25%), then right sidebar (30%)
    local bottom side
    bottom=$(tmux split-window -v -p 25 -t "$main" -PF '#{pane_id}')
    side=$(tmux split-window -h -p 30 -t "$main" -PF '#{pane_id}')

    # Force exact 70/30 split on the top panes (survives initial creation rounding)
    local win_width
    win_width=$(tmux display -t "$main" -p '#{window_width}')
    tmux resize-pane -t "$main" -x $((win_width * 70 / 100))

    # Focus main pane
    tmux select-pane -t "$main"

    if [ -n "$cmd" ]; then
        tmux send-keys -t "$main"   "$cmd" Enter
        tmux send-keys -t "$side"   "$cmd" Enter
        tmux send-keys -t "$bottom" "$cmd" Enter
    fi

    dbg "create_3pane_window: done (main=$main side=$side bottom=$bottom)"
}

ensure_session() {
    # Guarantees session + healthy host window exist
    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        dbg "ensure_session: no session, creating with host window"
        create_3pane_window "host"
        return
    fi

    # Session exists — check host window
    if ! has_window "host"; then
        dbg "ensure_session: host window missing, recreating"
        create_3pane_window "host"
        return
    fi

    # Host window exists — check pane count
    local panes
    panes=$(window_pane_count "host")
    if [ "$panes" != "3" ]; then
        dbg "ensure_session: host has $panes panes (expected 3), recreating"
        tmux kill-window -t "$SESSION:host"
        create_3pane_window "host"
    fi
}

attach_or_switch() {
    local wname="$1"
    if [ -n "$TMUX" ]; then
        dbg "attach_or_switch: already in tmux, selecting window '$wname'"
        tmux select-window -t "$SESSION:$wname"
    else
        dbg "attach_or_switch: attaching to session, window '$wname'"
        tmux select-window -t "$SESSION:$wname"
        exec tmux attach-session -t "$SESSION"
    fi
}

# ── dev up ───────────────────────────────────────────────────────────────────

wait_for_container() {
    local dir="$1"
    dbg "wait_for_container: polling (max 30s)..."
    local i=0 max=30
    while [ $i -lt $max ]; do
        local c
        c=$(get_project_container "$dir")
        if [ -n "$c" ]; then
            dbg "wait_for_container: found '$c' after ${i}s"
            echo "$c"
            return 0
        fi
        dbg "wait_for_container: not up yet (${i}s elapsed)"
        sleep 1
        i=$((i + 1))
    done
    die "Timed out waiting for container to start after ${max}s."
}

resend_exec_to_panes() {
    local wname="$1" exec_cmd="$2"
    dbg "resend_exec_to_panes: sending exec to all panes in '$wname'"
    local pane_ids
    pane_ids=(${(f)"$(tmux list-panes -t "$SESSION:$wname" -F '#{pane_id}')"})
    for pid in $pane_ids; do
        # Send Ctrl+C to kill any dead exec, then re-exec
        tmux send-keys -t "$pid" C-c
        tmux send-keys -t "$pid" "$exec_cmd" Enter
    done
}

cmd_up() {
    local project_name project_dir compose container shell exec_cmd
    project_name=$(get_project_name)
    project_dir="$(pwd)"
    compose="$project_dir/$COMPOSE_FILE"

    dbg "cmd_up: project=$project_name dir=$project_dir"

    local has_devcontainer=0
    [ -f "$compose" ] && has_devcontainer=1

    if [ "$has_devcontainer" -eq 0 ]; then
        # ── No devcontainer: plain local window ──────────────────────────────
        dbg "cmd_up: no .devcontainer, skipping docker steps"
        ensure_session

        if has_window "$project_name"; then
            info "Project '$project_name' already open."
            attach_or_switch "$project_name"
            return
        fi

        create_3pane_window "$project_name" "cd $project_dir"
        tmux set-option -t "$SESSION:$project_name" @project_dir "$project_dir"
        info "Project '$project_name' ready (local)."
        attach_or_switch "$project_name"
        return
    fi

    # ── Devcontainer path ─────────────────────────────────────────────────────

    # Step 1: Shared infrastructure
    ensure_postgres
    ensure_session

    # Step 2: Check if window already exists (Case A)
    if has_window "$project_name"; then
        local panes
        panes=$(window_pane_count "$project_name")
        dbg "cmd_up: window '$project_name' exists with $panes panes"

        if [ "$panes" != "3" ]; then
            dbg "cmd_up: wrong pane count, killing window"
            tmux kill-window -t "$SESSION:$project_name"
            # Fall through to Case B
        else
            # Check if container is alive
            container=$(get_project_container "$project_dir")
            if [ -z "$container" ]; then
                # Container dead — restart and re-exec
                info "Container stopped. Restarting..."
                docker compose -p "$project_name" -f "$compose" up -d
                container=$(wait_for_container "$project_dir")
                shell=$(get_shell "$container")
                exec_cmd="docker compose -p $project_name -f $compose exec $(get_service_name $project_dir) $shell"
                resend_exec_to_panes "$project_name" "$exec_cmd"
            fi
            info "Project '$project_name' already running."
            attach_or_switch "$project_name"
            return
        fi
    fi

    # Step 3: Case B — create new project window
    # Ensure container is running
    container=$(get_project_container "$project_dir")
    if [ -z "$container" ]; then
        info "Starting containers for $project_name..."
        docker compose -p "$project_name" -f "$compose" up -d
        container=$(wait_for_container "$project_dir")
    fi
    shell=$(get_shell "$container")
    local service
    service=$(get_service_name "$project_dir")
    exec_cmd="docker compose -p $project_name -f $compose exec $service $shell"
    info "Container: $container  Service: $service  Shell: $shell"

    # Create window with 3 panes, all exec'd into container
    create_3pane_window "$project_name" "$exec_cmd"

    # Store project dir as tmux user option on the window
    tmux set-option -t "$SESSION:$project_name" @project_dir "$project_dir"

    dbg "cmd_up: final window list:"
    tmux list-windows -t "$SESSION" -F '         #I: #W (#{window_panes} panes)' >&2 || true

    info "Project '$project_name' ready."
    attach_or_switch "$project_name"
}

# ── dev down ─────────────────────────────────────────────────────────────────

cmd_down() {
    local project_name project_dir compose
    project_name=$(get_project_name)
    project_dir="$(pwd)"
    compose="$project_dir/$COMPOSE_FILE"

    dbg "cmd_down: project=$project_name dir=$project_dir"

    # Kill the project window if it exists
    if tmux has-session -t "$SESSION" 2>/dev/null && has_window "$project_name"; then
        info "Removing window '$project_name'."
        tmux kill-window -t "$SESSION:$project_name"
    fi

    # Stop project containers
    if [ -f "$compose" ]; then
        info "Stopping containers for $project_name..."
        docker compose -p "$project_name" -f "$compose" down
    fi

    # Check if any project windows remain
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        local remaining
        remaining=$(project_window_count)
        dbg "cmd_down: $remaining project windows remaining"

        if [ "$remaining" -eq 0 ]; then
            info "No projects left. Stopping postgres and killing session."
            docker compose -f "$POSTGRES_COMPOSE" down 2>/dev/null || true
            tmux kill-session -t "$SESSION" 2>/dev/null || true
        fi
    else
        # Session already gone — clean up postgres
        docker compose -f "$POSTGRES_COMPOSE" down 2>/dev/null || true
    fi
}

# ── dev restart ──────────────────────────────────────────────────────────────

cmd_restart() {
    local project_name project_dir compose

    # Prefer @project_dir from the current tmux window — works even when pwd is
    # inside the container (where pwd returns /workspace, not the host path)
    if [ -n "$TMUX" ]; then
        local current_window
        current_window=$(tmux display-message -p '#W')
        project_dir=$(tmux show-option -t "$SESSION:$current_window" -v @project_dir 2>/dev/null) || true
        [ -n "$project_dir" ] && project_name=$(basename "$project_dir")
    fi

    # Fallback to pwd (when called from host shell outside tmux)
    if [ -z "$project_dir" ]; then
        project_dir="$(pwd)"
        project_name=$(get_project_name)
    fi

    compose="$project_dir/$COMPOSE_FILE"
    [ -f "$compose" ] || die "No $COMPOSE_FILE found. Run from the project directory or its tmux window."

    info "Restarting $project_name (window stays open)..."

    docker compose -p "$project_name" -f "$compose" down
    docker compose -p "$project_name" -f "$compose" up -d

    local container shell service exec_cmd
    container=$(wait_for_container "$project_dir")
    shell=$(get_shell "$container")
    service=$(get_service_name "$project_dir")
    exec_cmd="docker compose -p $project_name -f $compose exec $service $shell"

    if has_window "$project_name"; then
        resend_exec_to_panes "$project_name" "$exec_cmd"
        info "Restarted. All panes re-exec'd into $container."
        attach_or_switch "$project_name"
    else
        info "Container up. No window found — run: dev up"
    fi
}

# ── dev status ───────────────────────────────────────────────────────────────

cmd_status() {
    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        echo "No dev session running."
        return
    fi

    echo "Session: $SESSION"
    local windows
    windows=(${(f)"$(tmux list-windows -t "$SESSION" -F '#W')"})
    for wname in $windows; do
        if [ "$wname" = "host" ]; then
            printf "  %-20s (host shell)\n" "$wname"
        else
            local pdir status
            pdir=$(tmux show-option -t "$SESSION:$wname" -v @project_dir 2>/dev/null) || pdir="?"
            local container
            container=$(get_project_container "$pdir" 2>/dev/null)
            if [ -n "$container" ]; then
                status=$(docker ps --format '{{.Status}}' --filter "name=$container" 2>/dev/null)
            else
                status="not running"
            fi
            printf "  %-20s %-30s %s\n" "$wname" "$pdir" "$status"
        fi
    done
}

# ── dev sh ───────────────────────────────────────────────────────────────────

cmd_sh() {
    local project_dir project_name compose service
    project_dir="$(pwd)"
    project_name=$(get_project_name)
    compose="$project_dir/$COMPOSE_FILE"

    [ -f "$compose" ] || die "No $COMPOSE_FILE found in $(pwd)"

    service=$(docker ps --filter "label=com.docker.compose.project=$project_name" \
                        --filter "label=dev.role=app" \
                        --format '{{.Label "com.docker.compose.service"}}' 2>/dev/null | head -1)
    [ -n "$service" ] || die "No running app container found for $project_name. Run: dev up"

    exec docker compose -p "$project_name" -f "$compose" exec "$service" /bin/zsh
}

# ── dev help ─────────────────────────────────────────────────────────────────

cmd_help() {
    local cheatdir="$HOME/.config/dotfiles"
    case "${1:-}" in
        tmux)  cat "$cheatdir/tmux/tmux-cheatsheet.md" ;;
        nvim)  cat "$cheatdir/nvim/neovim-cheatsheet.md" ;;
        "")
            echo "dev up      Start project containers + add tmux window"
            echo "dev down    Stop project containers + remove window"
            echo "dev restart Restart containers + re-exec all panes"
            echo "dev status  Show all projects in session"
            echo "dev help    This message"
            echo "dev help tmux   tmux cheatsheet"
            echo "dev help nvim   neovim cheatsheet"
            ;;
        *)  die "Unknown topic: $1 (try: tmux, nvim)" ;;
    esac
}

# ── Dispatch ─────────────────────────────────────────────────────────────────

dbg "dispatch: args='${@}'"
dbg "dispatch: SESSION=$SESSION  COMPOSE_FILE=$COMPOSE_FILE"

case "${1:-}" in
    up)         cmd_up ;;
    down)       cmd_down ;;
    restart)    cmd_restart ;;
    sh)         cmd_sh ;;
    status)     cmd_status ;;
    help|-h)    cmd_help "${2:-}" ;;
    *)          cmd_help ;;
esac
