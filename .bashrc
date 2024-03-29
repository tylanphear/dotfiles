[[ $- == *i* ]] || return

if [[ $- != *l* ]]; then
    # Source .profile if it hasn't been (in non-login shells)
    source "${HOME}/.profile"
fi

export PLATFORM="$(uname -s)"
export SERVER="$(hostname | cut -d'.' -f1)"

function is_cygwin_or_mingw() {
    case "$PLATFORM" in
        MINGW*)  true ;;
        CYGWIN*) true ;;
        *)       false ;;
    esac
}

### Prompt stuff {

PROMPT_COMMAND='make_prompt'
function make_prompt() {
    case "$?" in
        0)       local E_CODE="";;
        148|146) local E_CODE="\[\e[1;33m(&)\e[m\]";;
        *)       local E_CODE="\[\e[1;31m(X)\e[m\]";;
    esac
    local JOBS="$(jobs -p | wc -l)"
    (( JOBS > 0 )) || JOBS=""
    local TIME="\A"
    local USER="\[\e[0;32m\]\u@\h\[\e[m\]"
    local DIR="\[\e[0;33m\]\w\[\e[m\]"
    export PS1="\n$USER ($TIME) $DIR${E_CODE:+ $E_CODE}${JOBS:+ [$JOBS]}\n\$ "
}

## }

### Bash functions {

if ! has mapfile; then
    function mapfile() {
        if [ "$1" = "-t" ]; then
            shift
        fi
        declare -a "$1"
        while IFS= read -r line; do
            eval "$1+=(\"$line\")"
        done
    }
fi

function mc() {
    mkdir -p $1 && cd $1
}
export -f mc

function test_init() {
    ( git init . &&
        git add . &&
        git commit -m"Initial state." ) > /dev/null
}
export -f test_init

function test_reset() {
    ( git checkout -- . &&
        git clean -d -f ) > /dev/null
}
export -f test_reset

function test_reinit() {
    rm -rf ./.git &&
        test_init
}
export -f test_reinit

function pbp() {
    local branch="$1"
    [[ -n "$branch" ]] &&
        git pull origin $branch --no-edit && build && git push origin $branch
}
export -f pbp

function vdiff() {
    git diff "$@" | view -
}
export -f vdiff

function f() {
    (nohup firefox "$@" >/dev/null 2>&1 &)
}
export -f f

function testgcc() {
    local lang driver
    case "$1" in
             -*) lang="c"   driver="gcc"       ;;
            c|C) lang="c"   driver="gcc"; shift;;
        cpp|CPP|\
        c++|C++) lang="c++" driver="g++"; shift;;
              *) return 1;
    esac
    $driver -x "$lang" - "$@"
}
export -f testgcc

# }

# Aliases
alias my='ps u -u $USER'
alias killmy='killall -9 -u $USER'
alias st='stty sane -ixon'
alias ls='ls --color=auto'
if command -v nvim &>/dev/null; then
    alias vim='nvim'
fi

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

add_to_path "$HOME/.local/bin"

if [[ -f "${HOME}/.site/bashrc" ]]; then
    source "${HOME}/.site/bashrc"
fi

if command -v nvim >/dev/null; then
    alias vim=$(command -v nvim)
fi

export EDITOR="$(command -v vim)"
export VISUAL="$(command -v vim)"
