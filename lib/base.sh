
die() {
    echo "$0: FATAL: $*" >&2
    exit 1
}

log() {
    echo "$script_name: $*" >&2
}

[ "$SCRIPT_ROOT_DIR" ] || die "SCRIPT_ROOT_DIR not set"

script_libdir="$SCRIPT_ROOT_DIR/lib"
script_name=$(basename "$0")

. $SCRIPT_ROOT_DIR/etc/site.cf
[ "$TARGET_ID" ] || die "TARGET_ID not set"
[ "$HOST_OS" ]   || die "missing HOST_OS"
export TARGET_ID

. $SCRIPT_ROOT_DIR/etc/targets/$TARGET_ID.cf
. $SCRIPT_ROOT_DIR/etc/hosts/$HOST_OS.cf
. $SCRIPT_ROOT_DIR/lib/$HOST_OS/hostfunc.sh

jailrun_cmd="$script_libdir/jailrun-$HOST_JAIL_TYPE"

get_builder_chroot_name() {
    echo -n "xorg-$TARGET_ID"
}

jailrun() {
    $script_libdir/jailrun-$HOST_JAIL_TYPE "$@"
    return $?
}

jailrun_root() {
    sudo TARGET_ID="$TARGET_ID" $script_libdir/jailrun-$HOST_JAIL_TYPE "$@"
    return $?
}
