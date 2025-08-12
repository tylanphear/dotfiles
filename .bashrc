[[ $- == *i* ]] || return

source ~/.shutil/functions.sh
if [[ -f "${HOME}/.site/bashrc" ]]; then
    source "${HOME}/.site/bashrc"
fi
source ~/.shutil/aliases.sh

PROMPT_COMMAND='make_prompt'
function make_prompt() {
    case "$?" in
        0)       local E_CODE="";;
        148|146) local E_CODE="\[\e[1;33m(&)\e[m\]";;
        *)       local E_CODE="\[\e[1;31m(X)\e[m\]";;
    esac
    # weird + 0 trick needed for MacOS `wc` which adds leading spaces to its output
    local JOBS="$(($(jobs -p | wc -l) + 0))"
    (( JOBS > 0 )) || JOBS=""
    local TIME="\A"
    local USER="\[\e[0;32m\]\u@\h\[\e[m\]"
    local DIR="\[\e[0;33m\]\w\[\e[m\]"
    export PS1="\n$USER ($TIME) $DIR${E_CODE:+ $E_CODE}${JOBS:+ [$JOBS]}\n\$ "
}

# Miscellanea
if [[ -d "${HOME}/bash_completion.d/" ]]; then
    mapfile -d $'\0' scripts -t < <(find "${HOME}/bash_completion.d/" -maxdepth 1 -type f -print0)
    for script in "${scripts[@]}"; do
        source "$script"
    done
    unset scripts
fi

if [ -t 1 ]; then
    # Disable <C-s> suspend to allow forward i-search
    stty start undef stop undef
fi

# Fix up arrow screwing up terminal history
shopt -s checkwinsize

# Awful and weird hack to avoid escaping '$' in completions (e.g. 'ls $FOO<TAB>' becoming 'ls \$FOO')
if type -a _filedir >/dev/null 2>&1 && grep -q 'compopt -o filenames 2>' < <(type -a _filedir); then
    eval "$(type -a _filedir | tail -n +2 | sed 's/compopt -o filenames 2>/compopt -o filenames -o noquote 2>/')"
fi
