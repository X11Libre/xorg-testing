set -e

log() {
    echo "VM: $*"
}

[ "$VM_DISK_IMAGE" ]    || VM_DISK_IMAGE="$SCRIPT_ROOT_DIR/vm/images/$OS_TYPE/$OS_TYPE-$OS_RELEASE-$OS_ARCH-ci.qcow2"
[ "$OS_TEMPLATE_TYPE" ] || OS_TEMPLATE_TYPE="qcow2.zstd"
[ "$OS_TEMPLATE_URL" ]  || OS_TEMPLATE_URL="https://basepackages.vnc.biz/metux/cloudimages/${OS_TYPE}/${OS_TYPE}-${OS_RELEASE}-${OS_ARCH}-ci.${OS_TEMPLATE_TYPE}"
[ "$TEMPLATE" ]         || TEMPLATE="$SCRIPT_ROOT_DIR/vm/templates/$OS_TYPE/$OS_TYPE-$OS_RELEASE-$OS_ARCH-ci.$OS_TEMPLATE_TYPE"
[ "$VM_NAME" ]          || VM_NAME="$OS_TYPE-$OS_RELEASE-$OS_ARCH"

if [ ! "$VM_QEMU_ARCH" ]; then
    case "$OS_ARCH" in
        amd64)
            export VM_QEMU_ARCH=x86_64
        ;;
        *)
            export VM_QEMU_ARCH="$OS_ARCH"
        ;;
    esac
    log "guessed VM_QEMU_ARCH: $VM_QEMU_ARCH"
fi

if [ ! "$VM_CORES" ]; then
    VM_CORES=`nproc`
fi

die() {
    echo "ERROR: $@" >&2
    exit 1
}

download_template() {
    mkdir -p `dirname "${TEMPLATE}"`
    rm -f "${TEMPLATE}.tmp"

    if [ -f "${TEMPLATE}" ]; then
        log "template already present: ${TEMPLATE}"
        return 0
    fi

    log "need to fetch template: ${TEMPLATE}"
    if [ ! "${OS_TEMPLATE_URL}" ]; then
        OS_TEMPLATE_URL="https://basepackages.vnc.biz/metux/cloudimages/${OS_TYPE}/${OS_TYPE}-${OS_RELEASE}-${OS_ARCH}-ci.${OS_TEMPLATE_TYPE}"
    fi
    wget "${OS_TEMPLATE_URL}" -O "${TEMPLATE}.tmp" && mv "${TEMPLATE}.tmp" "${TEMPLATE}"
}

unpack_image() {
    mkdir -p `dirname "${VM_DISK_IMAGE}"`
    rm -f "${VM_DISK_IMAGE}.tmp"

    if [ -f "${VM_DISK_IMAGE}" ]; then
        log "image already present: ${VM_DISK_IMAGE}"
        return 0
    fi

    download_template
    log "uncompressing image template ${TEMPLATE}"
    case "${TEMPLATE}" in
        *.zstd | *.zst)
            time zstd -d "${TEMPLATE}" -o "${VM_DISK_IMAGE}.tmp" && mv "${VM_DISK_IMAGE}.tmp" "${VM_DISK_IMAGE}"
        ;;
        *.xz)
            time xz -d --stdout "${TEMPLATE}" > "${VM_DISK_IMAGE}.tmp" && mv "${VM_DISK_IMAGE}.tmp" "${VM_DISK_IMAGE}"
        ;;
        *)
            die "unsupported compression format for ${TEMPLATE}"
        ;;
    esac
    log "finished image decompression"
}

vm_opt_bios() {
    if [ "${OS_EFI}" ]; then
        echo -n "-bios /usr/share/ovmf/OVMF.fd"
    fi
}

vm_cloudinit() {
    if [ "$VM_CLOUDINIT" ]; then
        needvar OS_TYPE
        needvar OS_RELEASE
        needvar OS_ARCH
        log "using cloudinit: $VM_CLOUDINIT"
        ( cd $SCRIPT_ROOT_DIR/etc/vm/cloudinit/$VM_CLOUDINIT && \
            genisoimage \
                -output $SCRIPT_ROOT_DIR/vm/images/${OS_TYPE}/${OS_TYPE}-${OS_RELEASE}-${OS_ARCH}-cloudinit.iso \
                -volid cidata -rational-rock -joliet \
                -input-charset utf-8 \
                user-data meta-data network-config
        )
    else
        log "no cloudinit template selected. skipping"
    fi
}

vm_opt_cloudinit() {
    if [ "$VM_CLOUDINIT" ]; then
        echo "-drive file=$SCRIPT_ROOT_DIR/vm/images/${OS_TYPE}/${OS_TYPE}-${OS_RELEASE}-${OS_ARCH}-cloudinit.iso,index=1,media=cdrom"
    fi
}

vm_pidfile() {
    mkdir -p "$SCRIPT_ROOT_DIR/vm/pid"
    echo -n "$SCRIPT_ROOT_DIR/vm/pid/$OS_TYPE-$OS_RELEASE-$OS_ARCH.pid"
}

vm_start() {
    unpack_image
    vm_cloudinit
    qemu-system-$VM_QEMU_ARCH \
        -pidfile `vm_pidfile` \
        -name "$VM_NAME" \
        -smp "$VM_CORES" \
        -m "$VM_MEMSIZE" \
        -hda $VM_DISK_IMAGE \
        -enable-kvm \
        -machine q35 \
        -cpu max \
        -k de_de \
        -nic user,model=virtio-net-pci,hostfwd=tcp::${VM_SSH_PORT}-:22 \
        `vm_opt_bios` `vm_opt_cloudinit` \
        "$@"
}

boot_vm_daemon() {
    vm_start --daemonize -display none
}

boot_vm_console() {
    vm_start -nographic -serial mon:stdio "$@"
}

boot_vm_graphics() {
    vm_start -vga std "$@"
}

vm_exec() {
    ssh -p "$VM_SSH_PORT" root@localhost "$@"
}

vm_install_netbsd() {
    if [ "$VM_PACKAGES" ]; then
        vm_exec pkgin -y install $VM_PACKAGES
    fi
}

vm_install_freebsd() {
    if [ "$VM_PACKAGES" ]; then
        vm_exec pkg -4 update
        vm_exec pkg -4 install -y $VM_PACKAGES
    fi
}

vm_install_openindiana() {
    if [ "$VM_PACKAGES" ]; then
        vm_exec pkg -4 install $VM_PACKAGES
    fi
}

vm_install_packages() {
    case "$OS_TYPE" in
        netbsd)
            vm_install_netbsd "$@"
        ;;
        freebsd)
            vm_install_freebsd "$@"
        ;;
        openindiana)
            vm_install_openindiana "$@"
        ;;
        *)
            die "vm_install_packages: unknown OS type \"$VM_OS_TYPE\""
        ;;
    esac
}

vm_sync_xorg_testing() {
    local prefix="$SCRIPT_ROOT_DIR"
    rm -Rf .trans.tmp
    mkdir -p .trans.tmp
    cp --preserve -R $prefix/etc $prefix/lib $prefix/build-* $prefix/vm-boot-* .trans.tmp
    scp -P "$VM_SSH_PORT" -r .trans.tmp/* root@localhost:/xorg-testing/
    rm -Rf .trans.tmp
}

vm_build_testing_jail() {
    vm_sync_xorg_testing
    vm_install_packages
    ssh -p "$VM_SSH_PORT" root@localhost "cd /xorg-testing && ./build-testing-jail"
}
