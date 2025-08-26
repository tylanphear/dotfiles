[[ $- == *i* ]] || return

source ~/.shutil/functions.sh
if [[ -f "${HOME}/.site/zshrc" ]]; then
    source "${HOME}/.site/zshrc"
fi
source ~/.shutil/aliases.sh

function make_prompt() {
    case "$?" in
        0)       local E_CODE="";;
        148|146) local E_CODE="%B%F{yellow}(&)%f%b";;
        *)       local E_CODE="%B%F{red}(X)%f%b";;
    esac
    local JOBS="%(1j. [%j].)"
    local TIME="%T"
    local USER="%F{green}%n@%m%f"
    local DIR="%F{yellow}%d%f"
    local NL=$'\n'
    local GIT_BRANCH="$(git branch --show-current 2>/dev/null)"
    export PS1="${NL}$USER ($TIME) $DIR${E_CODE:+ $E_CODE}${JOBS}${GIT_BRANCH:+ ($GIT_BRANCH)}${NL}\$ "
}
function precmd() { make_prompt; }

bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
