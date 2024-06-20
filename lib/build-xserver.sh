#!/usr/bin/env bash

# execute me in ONLY in jail, never on host

set -e
set +x
SCRIPT_ROOT_DIR="$(cd "$(dirname "$0")/../" && pwd -P)"

. $SCRIPT_ROOT_DIR/lib/builder.sh

TARGET_CC_ARCH=$(cc -dumpmachine)
ARCH_LIBDIR="lib/$TARGET_CC_ARCH/"

# fixme: this could be os/distro specific
export PKG_CONFIG_PATH="$XORG_PREFIX/share/pkgconfig:$XORG_PREFIX/lib/pkgconfig:$XORG_PREFIX/$ARCH_LIBDIR/pkgconfig:$XORG_PREFIX/libdata/pkgconfig:/usr/local/libdata"

build_package xorg-util-macros
build_package xorgproto
build_package xorg-font-util
build_package libdrm
build_package xserver
build_package xkeyboard-config
build_package xkbcomp
build_package font-xfree86-type-1

for i in $XORG_DRIVERS ; do
    build_package $i
done

fc-cache
