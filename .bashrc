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

function build() {
    build_setup build "$@"
}

function vtest() {
    local BV=32
    if [[ $(uname -m) == "x86_64" ]]; then
        BV=64
    fi
    local args=("--install_directory=$VECTORCAST_DIR" "-bv=$BV" "-def" "$@")
    python $PYTHONPATH/vector/testsuite/run.py "${args[@]}"
}
export -f vtest

function mc() {
    mkdir -p $1 && cd $1
}
export -f mc

function cs {
    if [[ -n "${BLD_SRC}" ]]; then
        local BUILD_ROOT="$BLD_SRC/.."
        BUILD_ROOT=$(cd "$BUILD_ROOT"; pwd)
        if [[ "$(pwd)" != "$BUILD_ROOT" ]]; then
            cd $BUILD_ROOT
        fi
    fi
}
export -f cs

function bs {
    build_setup checkout "$@" &&
        export VCPYTHONPATH=$PYTHONPATH &&
        cs
}
export -f bs

function s_ {
    local OLD="$OLDPWD"
    bs $(basename $(pwd))
    export OLDPWD="$OLD"
}
export -f s_

function cb {
    if [[ -n "${BLD_SRC}" ]]; then
        local id="$1"
        if [[ -z "$id" ]]; then
            local re="\_\_([0-9]+)\_"
            if [[ "$(cs && git rev-parse --abbrev-ref HEAD)" =~ $re ]]; then
                id="${BASH_REMATCH[1]}"
            fi
            if [[ -z "$id" ]] || [[ "$id" = "HEAD" ]]; then
                echo "Tried to find a case number, found: $id"
                return 1
            fi
        fi
        mc "$HOME/cases/$id"
    fi
}
export -f cb

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

function vcastcfg {
    if [[ -z "${VECTORCAST_DIR}" ]]; then
        echo 'No VectorCAST dir. Run build_setup'
        return 1
    fi
    if [[ -z "$1" ]]; then
        echo "No arguments given."
        return 1
    fi
    local template="$2"
    if [[ -z "$template" ]] && [[ ! -e ./CCAST_.CFG ]]; then
        local ext="${1##*.}" # get file extension
        ext="${ext^^}" # capitalize
        local file_lang
        case "$ext" in
              C) file_lang="C"   ;;
            C??) file_lang="CPP" ;;
              *) echo "Invalid file given: \"$1\". Not C or C++"
                 return 1
        ;; esac
        if [[ "$PLATFORM" == CYGWIN* ]]; then
            template="BUILTIN_MINGW_63_${file_lang}"
        else
            template="GNU_${file_lang}_48"
        fi
    fi
    if [[ -n "$template" ]]; then
        $VECTORCAST_DIR/clicast -lc TEM $template
    fi
    local file="$1"
    _VCAST_ENV_FILE="${file%.*}.env"
    $VECTORCAST_DIR/clicast -lc EN SCRIPT QUICK $file &&
        sed 's/\.UUT/.SBF/' -i "$_VCAST_ENV_FILE"
}
export -f vcastcfg

function vcastenv {
    vcastcfg $@ &&
        $VECTORCAST_DIR/clicast -lc EN BUILD $_VCAST_ENV_FILE
    unset _VCAST_ENV_FILE
}
export -f vcastenv

function vcastqt {
    $VECTORCAST_DIR/vcastqt $@ &
}
export -f vcastqt

function manage_test {
    function safe_exec {
        (unset $(env | sed -ne 's/BASH_FUNC_\(\w*\)%%=\(.*\)/\1/p') && $@)
    }
    safe_exec $MANAGE_DIR/scripts/manage.sh -build-exec -t $@
}
export -f manage_test

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

#export VCAST_MESSAGE_TIMESTAMPS=1
#export VCAST_DEBUG_LEVELS=normal,trace,exception,syscmd,timing,vresult_trace,sql
#export VCAST_DEBUG_FILENAME=vdebug
export VCAST_VRESULT_ABORT_ON_ERROR=1
export VCAST_NO_FILE_TRUNCATION=1
export VECTOR_USE_CCACHE=1
export VCAST_FORCE_OVERWRITE_ENV_DIR=1

EDITOR="$(command -v vim)"; export EDITOR
VISUAL="$(command -v vim)"; export VISUAL
