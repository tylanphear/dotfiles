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
    if [ -z "$1" ]; then
        return 1;
    fi
    if ! in_path "$1"; then
        export PATH="$1:$PATH"
    fi
}
_export_func add_to_path

push_path() {
    if [ -z "$1" ]; then
        return 1;
    fi
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
