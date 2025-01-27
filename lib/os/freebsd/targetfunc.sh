# this file is only included on $TARGET_OS="freebsd"
target_bootstrap_chroot() {
    needvar TARGET_OS TARGET_RELEASE TARGET_ARCH

    [ "$HOST_OS_TYPE" == "freebsd" ] || die "FreeBSD jails are only supported on FreeBSD hosts"

    local chroot_dir="$(get_builder_chroot_dir)"
    local tarball_dir="$(get_builder_tarball_dir)"
    local tarball_url="https://download.freebsd.org/ftp/releases/$TARGET_ARCH/$TARGET_ARCH/$TARGET_RELEASE-RELEASE/base.txz"
    local tarball_fn="$tarball_dir/$TARGET_RELEASE-RELEASE-base.txz"

    host_fetch_tarball "$tarball_url" "$tarball_fn"

    mkdir -p "$chroot_dir"
    chflags -R noschg "$chroot_dir"
    rm -Rf "$chroot_dir"
    mkdir -p "$chroot_dir"
    tar -xf "$tarball_fn" -C "$chroot_dir"
    chflags -R noschg "$chroot_dir"

    if [ -f /etc/resolv.conf ]; then cp /etc/resolv.conf "$chroot_dir/etc/" ; fi
    if [ -f /etc/localtime ]; then cp /etc/localtime   "$chroot_dir/etc/" ; fi

    # fixme: put this into jail, so we're independent of guest OS
    freebsd-update -y -b "$chroot_dir" fetch install
}
