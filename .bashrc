PLATFORM="$(uname -s)"
export SERVER="$(hostname | cut -d'.' -f1)"
### Prompt stuff {

function nonzero_return() {
    [[ $? -eq 0 ]] || echo "(X)"
}
export -f nonzero_return

_TIME="\A"
_USER="\[\e[32m\]\u@\h\[\e[m\]"
_DIR="\[\e[33m\]\w\[\e[m\]"
_E_CODE="\[\e[31m\]\`nonzero_return\`\[\e[m\]"
export PS1="\n$_USER ($_TIME) $_DIR $_E_CODE\n\$ "

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

# Miscellanea
if [[ -d "${HOME}/bash_completion.d/" ]]; then
    mapfile -d $'\0' scripts -t < <(find "${HOME}/bash_completion.d/" -maxdepth 1 -type f -print0)
    for script in "${scripts[@]}"; do
        source "$script"
    done
    unset scripts
fi

### Key Bindings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Fix up arrow screwing up terminal history
shopt -s checkwinsize
# Disable <C-s> suspend to allow forward i-search
stty start undef stop undef

EDITOR="$(command -v vim)"; export EDITOR
VISUAL="$(command -v vim)"; export VISUAL
