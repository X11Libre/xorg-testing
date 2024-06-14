chroot_bootstrap_distro() {
    local chroot_os="$1"
    local chroot_release="$2"
    local chroot_dir="$3"
    local chroot_prefix="$(dirname $chroot_dir)"
    local chroot_lock="$chroot_dir.LOCK"

    if [ ! "$chroot_dir" ]; then
        die "schroot_bootstrap_distro <os> <release> <dir>"
    fi

    if [ -f "$chroot_lock" ]; then
        sudo rm -Rf "$chroot_dir"
        sudo rm -f "$chroot_lock"
    fi

    if [ -d "$chroot_dir" ]; then
        log "chroot for $chroot_os $chroot_release already exists"
        log "to rebuild it, remove $chroot_dir"
        return 0
    fi

    sudo mkdir -p "$chroot_prefix"
    sudo touch "$chroot_lock"

    log "need to boostrap $chroot_os $chroot_release chroot dir"

    case "$TARGET_OS" in
        debian)
            sudo mmdebstrap "$chroot_release" "$chroot_dir"
        ;;
        *)
            die "bootstrapping OS chroot for $chroot_os / $chroot_release not supported"
        ;;
    esac

    sudo rm -f "$chroot_lock"
}

builder_bootstrap() {
    needvar TARGET_RELEASE TARGET_PACKAGES HOST_CHROOT_DIR

    # call the host-OS specific setup function
    host_os_setup

    case "$HOST_JAIL_TYPE" in
        schroot)
            chroot_dir="$HOST_CHROOT_DIR/$(get_builder_chroot_name $TARGET_ID)"
            chroot_bootstrap_distro "$TARGET_OS" "$TARGET_RELEASE" "$chroot_dir"
            jailrun register "$chroot_dir"
            jailrun install $TARGET_PACKAGES
        ;;
        *)
            die "unsupport HOST_JAIL_TYPE: $HOST_JAIL_TYPE"
        ;;
    esac
}
