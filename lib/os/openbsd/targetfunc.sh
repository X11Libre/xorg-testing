# this file is only included on $TARGET_OS="openbsd"

__copytojail() {
    local fn="$1"
    local dn="$(dirname $fn)"
    local chroot_dir="$(get_builder_chroot_dir)"

    log "copying to chroot: $fn"
    mkdir -p "$chroot_dir/$dn"
    cp "$fn" "$chroot_dir/$dn"
}

copytojail() {
    for i in "$@" ; do
        __copytojail "$i"
    done
}

target_bootstrap_chroot() {
    needvar TARGET_OS TARGET_RELEASE TARGET_ARCH TARGET_MIRROR TARGET_SETS

    [ "$HOST_OS_TYPE" == "openbsd" ] || die "OpenBSD chroot's are only supported on OpenBSD hosts"

    local chroot_dir="$(get_builder_chroot_dir)"
    local tarball_dir="$(get_builder_tarball_dir)"

    local tarball_dir="$(get_builder_tarball_dir)/openbsd/$TARGET_RELEASE/$TARGET_ARCH"
    local tarball_mirror="$TARGET_MIRROR/$TARGET_RELEASE/$TARGET_ARCH"

    mkdir -p "$tarball_dir/binary/sets"
    for i in ${TARGET_SETS}; do
        host_fetch_tarball "$tarball_mirror/$i.tgz" "$tarball_dir/$i.tgz"
        release_sets="$release_sets $i.tgz"
    done

    rm -Rf "$chroot_dir"
    mkdir -p "$chroot_dir"

    log "bootstrap: unpacking tarballs"
    for i in $TARGET_SETS; do
        tar -xzf "$tarball_dir/$i.tgz" -C "$chroot_dir"
    done

    log "bootstrap: now creating /dev"
    mkdir -p "$chroot_dir/dev"
    ( cd "$chroot_dir/dev" && echo "in chroot dir" && pwd && /dev/MAKEDEV all )

    log "bootstrap: copying /etc files"
    copytojail /etc/installurl /etc/resolv.conf /etc/localtime /etc/passwd \
               /etc/master.passwd /etc/pwd.db /etc/spwd.db /etc/ssl/cert.pem
}
