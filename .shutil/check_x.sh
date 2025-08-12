if has xset && ! xset -q >/dev/null; then
    printf "WARNING!\nWARNING! Not able to connect to X Window Server.\nWARNING!\n"
    # Read one character -- if it's `q`, then quit
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
