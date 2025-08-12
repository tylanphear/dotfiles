alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias my='ps u -u $USER'
alias killmy='killall -9 -u $USER'
alias st='stty sane -ixon'
alias ls='ls --color=auto'
if command -v nvim >/dev/null; then
    alias vim="$(command -v nvim)"
    alias view="vim -R"
    alias nview="nvim -R"
fi
