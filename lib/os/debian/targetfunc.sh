# this file is only included on $TARGET_OS="debian"
target_bootstrap_chroot() {
    needvar TARGET_OS TARGET_RELEASE
    local chroot_dir="$(get_builder_chroot_dir)"
    sudo mmdebstrap "$TARGET_RELEASE" "$chroot_dir"
}
