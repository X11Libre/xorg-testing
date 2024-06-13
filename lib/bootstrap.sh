chroot_bootstrap_distro() {
    local chroot_dir="$(get_builder_chroot_dir)"
    local chroot_prefix="$(dirname $chroot_dir)"
    local chroot_lock="$chroot_dir.LOCK"
    needvar TARGET_OS TARGET_RELEASE

    if [ ! "$chroot_dir" ]; then
        die "schroot_bootstrap_distro <os> <release> <dir>"
    fi

    if [ -f "$chroot_lock" ]; then
        sudo rm -Rf "$chroot_dir"
        sudo rm -f "$chroot_lock"
    fi

    if [ -d "$chroot_dir" ]; then
        log "chroot for $TARGET_OS $TARGET_RELEASE already exists"
        log "to rebuild it, remove $chroot_dir"
        return 0
    fi

    sudo mkdir -p "$chroot_prefix"
    sudo touch "$chroot_lock"

    log "need to boostrap $TARGET_OS $TARGET_RELEASE chroot dir $chroot_dir"

    target_bootstrap_chroot

    sudo rm -f "$chroot_lock"
}

builder_bootstrap() {
    needvar TARGET_PACKAGES

    # call the host-OS specific setup function
    host_os_setup

    chroot_bootstrap_distro

    jailrun register "$(get_builder_chroot_dir)"
    jailrun install $TARGET_PACKAGES
}
