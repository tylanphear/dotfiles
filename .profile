alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

if [ -n "$BASH_VERSION" ]; then
    _export_func() { export -f "$1"; }
else
    _export_func() { :; }
fi

in_path() {
    [ -n "$1" ] && case ":$PATH:" in *":$1:"*) return 0;; esac
    return 1;
}
_export_func in_path

remove_from_path() {
    if ! in_path "$1"; then
        return;
    fi
    _path="$(printf "%s" "$1" | sed 's|/|\\/|g')"
    PATH="$(printf "%s" "$PATH" | sed -e "s/\(:$_path\|$_path:\)//")"; export PATH
    echo "$PATH"
    unset _path
}
_export_func remove_from_path

add_to_path() {
    if ! in_path "$1"; then
        export PATH="$1:$PATH"
    fi
}
_export_func add_to_path

push_path() {
    export PATH="$1:$PATH"
    echo "$PATH"
}
_export_func push_path

pop_path() {
    PATH="$(printf "%s" "$PATH" | cut -d':' -f 2-)"; export PATH
    echo "$PATH"
}
_export_func pop_path

has() {
    command -v "$1" >/dev/null 2>&1
}
_export_func has

if ! has realpath; then
    realpath() {
        readlink -f "$1"
    }
    _export_func realpath
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
