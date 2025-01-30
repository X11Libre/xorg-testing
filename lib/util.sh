die() {
    echo "$0: FATAL: $*" >&2
    exit 1
}

log() {
    echo "$script_name: $*" >&2
}

needvar() {
    for v in "$@"; do
        [ "${!v}" ] || die "missing config variable $v"
    done
}
