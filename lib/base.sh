
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

needvar SCRIPT_ROOT_DIR

script_libdir="$SCRIPT_ROOT_DIR/lib"
script_name=$(basename "$0")

. $SCRIPT_ROOT_DIR/etc/site.cf
needvar TARGET_ID HOST_OS
export TARGET_ID

. $SCRIPT_ROOT_DIR/etc/targets/$TARGET_ID.cf
. $SCRIPT_ROOT_DIR/etc/hosts/$HOST_OS.cf
. $SCRIPT_ROOT_DIR/lib/$HOST_OS/hostfunc.sh

needvar HOST_JAIL_TYPE
jailrun_cmd="$script_libdir/jailrun-$HOST_JAIL_TYPE"

get_builder_chroot_name() {
    needvar TARGET_ID
    echo -n "xorg-$TARGET_ID"
}

jailrun() {
    needvar HOST_JAIL_TYPE
    $script_libdir/jailrun-$HOST_JAIL_TYPE "$@"
    return $?
}

jailrun_root() {
    needvar TARGET_ID
    sudo TARGET_ID="$TARGET_ID" $script_libdir/jailrun-$HOST_JAIL_TYPE "$@"
    return $?
}
