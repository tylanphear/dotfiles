alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

in_path() {
    [ -n "$1" ] && case ":$PATH:" in *":$1:"*) return 0;; esac
    return 1;
}

remove_from_path() {
    if in_path "$1"; then
        _path="$(printf "%s" "$1" | sed 's|/|\\/|g')"
        PATH="$(printf "%s" "$PATH" | sed -e "s/\(:$_path\|$_path:\)//")"; export PATH
        echo "$PATH"
        unset _path
    fi
}

add_to_path() {
    if ! in_path "$1"; then
        export PATH="$1:$PATH"
    fi
}

push_path() {
    export PATH="$1:$PATH"
    echo "$PATH"
}

pop_path() {
    PATH="$(printf "%s" "$PATH" | cut -d':' -f 2-)"; export PATH
    echo "$PATH"
}

has() {
    command -v "$1" >/dev/null 2>&1
}

if ! has realpath; then
    realpath() {
        readlink -f "$1"
    }
fi

if has xset && ! xset -q >/dev/null; then
    printf "WARNING!\nWARNING! Not able to connect to X Window Server.\nWARNING!\n"
    # Read one character -- if it's `q`, then quit.
    tty_settings="$(stty -g)"
    stty -echo -icanon min 1 time 0
    trap 'stty "$tty_settings"' INT
    ans="$(dd bs=1 count=1 2>/dev/null; echo .)"
    ans="${ans%.}"
    if [ "$ans" = "q" ]; then
        exit
    fi
    stty "$tty_settings"
    unset ans tty_settings
    trap - INT
fi

stty -ixon

if [ -n "$(command -v tmux)" ]; then
    if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
        tmux attach-session -t "$USER" || tmux new-session -s "$USER"
        exit
    fi
fi
