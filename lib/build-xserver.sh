#!/usr/bin/env bash

# execute me in ONLY in jail, never on host

set -e
set +x
SCRIPT_ROOT_DIR="$(cd "$(dirname "$0")/../" && pwd -P)"

. $SCRIPT_ROOT_DIR/lib/builder.sh

if [ ! "$CC" ]; then
    if mycc=`which cc` >/dev/null ; then
        export CC="$mycc"
    elif mycc=`which gcc` >/dev/null ; then
        export CC="$mycc"
    elif mycc=`which clang` >/dev/null ; then
        export CC="$mycc"
    else
        die "cant find a C compiler"
    fi
fi

log "C-Compiler: $CC"

TARGET_CC_ARCH=$($CC -dumpmachine)
ARCH_LIBDIR="lib/$TARGET_CC_ARCH/"

# fixme: speciality for Illumos
if [ "$(uname)" == "SunOS" ]; then
    mkdir -p /var/run/opengl/include/ /usr/include/GL/internal
    ln -sf ../../../../usr/include/mesa/gl.h var/run/opengl/include/gl.h
    ln -sf ../../../../usr/include/mesa/glext.h var/run/opengl/include/glext.h
    ln -sf ../../mesa/internal/dri_interface.h /usr/include/GL/internal/dri_interface.h
    build_ninja
fi

# fixme: this could be os/distro specific
export PKG_CONFIG_PATH="$XORG_PREFIX/share/pkgconfig:$XORG_PREFIX/lib/pkgconfig:$XORG_PREFIX/$ARCH_LIBDIR/pkgconfig:$XORG_PREFIX/libdata/pkgconfig:/usr/local/libdata"

build_package xorg-util-macros
build_package xorgproto
build_package xorg-font-util
build_package libdrm
build_package xcb-proto
build_package libxcb
build_package libxcb-wm
build_package libxcb-util

for i in $XORG_EXTRA_DEPS ; do
    build_package $i
done

# special hack for Illumos
if [ "$(uname)" == "SunOS" ]; then
    pip install strenum
fi

build_package xserver
build_package xkeyboard-config
build_package xkbcomp
build_package font-xfree86-type-1

for i in $XORG_DRIVERS ; do
    build_package $i
done

fc-cache
