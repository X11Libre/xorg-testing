target_bootstrap_chroot() {
    log "bootstrapping Illumos target from host"

    needvar HOST_CHROOT_RPOOL

    [ "$HOST_OS_TYPE" == "$TARGET_OS" ] || die "host $HOST_OS_TYPE mismatch target $TARGET_OS"

    local chroot_dir="$(get_builder_chroot_dir)"
    local chroot_name="$(get_builder_chroot_name)"
    local chroot_rpool="$HOST_CHROOT_RPOOL/$chroot_name"

    mkdir -p $(dirname "$chroot_dir")
    log "zfs create $chroot_rpool"
    zfs create $chroot_rpool || true

    # FIXME: should support bootstrapping other releases, too
    log "initialize chroot"
    mkdir -p "$chroot_dir/var/pkg" \
             "$chroot_dir/tmp" \
             "$chroot_dir/etc" \
             "$chroot_dir/dev" \
             "$chroot_dir/devices" \
             "$chroot_dir/proc"
    cp /var/pkg/pkg5.image "$chroot_dir/var/pkg"

    log "installing initial packages"
    pkg -R "$chroot_dir" install pkg bash

    if [ ! -f "$chroot_dir/usr/include/sys/srn.h" ]; then
        log "need to copy sys/srn.h"
        cp $SCRIPT_ROOT_DIR/lib/os/illumos/files/srn.h "$chroot_dir/usr/include/sys/srn.h"
    fi
}
