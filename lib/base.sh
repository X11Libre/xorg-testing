
. $SCRIPT_ROOT_DIR/lib/util.sh

needvar SCRIPT_ROOT_DIR

script_libdir="$SCRIPT_ROOT_DIR/lib"
script_name=$(basename "$0")

. $SCRIPT_ROOT_DIR/etc/site.cf

## probe the host OS
if [ ! "$HOST_OS" ]; then
    case $(uname) in
        Linux)
            log "detected Linux - assuming debian (set HOST_OS if I'm wrong)"
            export HOST_OS="debian"
        ;;
        FreeBSD)
            log "detected FreeBSD"
            export HOST_OS="freebsd"
        ;;
        NetBSD)
            log "detected NetBSD"
            export HOST_OS="netbsd"
        ;;
        OpenBSD)
            log "detected OpenBSD"
            export HOST_OS="openbsd"
        ;;
        SunOS)
            log "detected SunOS"
            export HOST_OS="illumos"
        ;;
        *)
            die "unknown uname: $(uname)"
        ;;
    esac
fi

. $SCRIPT_ROOT_DIR/etc/hosts/$HOST_OS.cf

needvar TARGET_ID
export TARGET_ID

. $SCRIPT_ROOT_DIR/etc/targets/$TARGET_ID.cf
. $SCRIPT_ROOT_DIR/lib/os/$HOST_OS/hostfunc.sh

needvar HOST_JAIL_TYPE

needvar TARGET_OS
. $SCRIPT_ROOT_DIR/lib/os/$TARGET_OS/targetfunc.sh

get_builder_chroot_name() {
    needvar TARGET_ID
    echo -n "xorg-$TARGET_ID"
}

get_builder_chroot_dir() {
    needvar TARGET_ID HOST_CHROOT_DIR
    echo -n "$HOST_CHROOT_DIR/$(get_builder_chroot_name $TARGET_ID)"
}

get_builder_tarball_dir() {
    needvar HOST_CHROOT_DIR
    echo -n "$HOST_CHROOT_DIR/tarballs"
}

jailrun() {
    needvar HOST_JAIL_TYPE
    $script_libdir/jail/jailrun-$HOST_JAIL_TYPE "$@"
    return $?
}

jailrun_root() {
    needvar TARGET_ID
    sudo TARGET_ID="$TARGET_ID" $script_libdir/jail/jailrun-$HOST_JAIL_TYPE "$@"
    return $?
}
