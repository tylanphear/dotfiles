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
function mc {
    mkdir -p $1 && cd $1
}
export -f mc

function test_init {
    ( git init . &&
        git add . &&
        git commit -m"Initial state." ) > /dev/null
}
export -f test_init

function test_reset {
    ( git checkout -- . &&
        git clean -d -f ) > /dev/null
}
export -f test_reset

function test_reinit {
    rm -rf ./.git &&
        test_init
}
export -f test_reinit

function push_path() {
    export PATH="$1:$PATH"
    echo $PATH
}
export -f push_path

function pop_path() {
    export PATH=$(printf "%s" $PATH | cut -d':' -f 2-)
    echo $PATH
}
export -f pop_path

function vdiff() {
    git diff $@ | view -
}
export -f vdiff

function f() {
    (nohup firefox $@ >/dev/null 2>&1 &)
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

### Key Bindings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Fix up arrow screwing up terminal history
shopt -s checkwinsize
# Disable <C-s> suspend to allow forward i-search
stty start undef stop undef

export EDITOR="$(command -v vim)"
export VISUAL="$(command -v vim)"
