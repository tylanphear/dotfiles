alias dotfiles='command -p git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

add_to_path() {
   [ ":$PATH:" = *":$1:"* ] || export PATH="$1:$PATH"
}

if [ -n "`command -v xset`" ] && ! xset -q >/dev/null; then
    echo -e "WARNING!\nWARNING! Not able to connect to X Window Server.\nWARNING!"
    read -s -N1 ans && [ "$ans" = "q" ] && exit; unset ans
fi

stty -ixon

if [ -n "`command -v tmux`" ]; then
    if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
        tmux attach-session -t "$USER" || tmux new-session -s "$USER"
        exit
    fi
fi
