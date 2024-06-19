. $SCRIPT_ROOT_DIR/lib/base.sh
. $SCRIPT_ROOT_DIR/etc/sources.cf

get_workdir() {
    local id="$1"
    needvar TARGET_WORKDIR
    echo -n "$TARGET_WORKDIR/$id.git"
}

get_source_repo() {
    local id="$1"
    local var="${id^^}"
    var="SOURCE_${var//-/_}_REPO"
    var="${!var}"
    [ "$var" ] || die "missing source repo for: $id"
    echo "${var}"
}

get_source_ref() {
    local id="$1"
    id="${id^^}"
    id="SOURCE_${id//-/_}_REF"
    echo "${!id}"
}

get_pkg_args() {
    local id="$1"
    id="${id^^}"
    id="PACKAGE_${id//-/_}_BUILD_ARGS"
    echo "${!id}"
}

clone_work_repo() {
    local id="$1"
    local repo="$(get_source_repo "$id")"
    local ref="$(get_source_ref "$id")"
    local workdir="$(get_workdir "$id")"

    if [ -f "$workdir/.git/config" ]; then
        log "git repo $workdir already cloned. remove it to reclone"
        return 0
    fi

    mark_undone "$1"
    git clone $repo $workdir --branch="$ref" $GIT_CLONE_ARGS
}

clone_work_repos() {
    while [ "$1" ]; do
        clone_work_repo "$1"
        shift
    done
}

mark_done() {
    local id="$1"
    needvar TARGET_WORKDIR
    git --git-dir=$(get_workdir "$id")/.git rev-parse HEAD > "$TARGET_WORKDIR/$id.DONE"
}

mark_undone() {
    local id="$1"
    needvar TARGET_WORKDIR
    rm -f "$TARGET_WORKDIR/$id.DONE"
}

if_done() {
    local id="$1"
    needvar TARGET_WORKDIR

    local newrev="$(git --git-dir=$(get_workdir "$id")/.git rev-parse HEAD)"
    local oldrev="$(cat $TARGET_WORKDIR/$id.DONE 2>/dev/null || true)"

    log "$id: oldrev=$oldrev newrev=$newrev"

    if [ "$oldrev" == "$newrev" ]; then
        log "package $id already built. skipping"
        return 0
    else
        return 1
    fi
}

build_package() {
    local id="$1"
    local workdir=$(get_workdir "$id")
    local args=$(get_pkg_args "$id")
    shift

    clone_work_repo "$id"

    if_done "$id" && return 0

    rm -Rf $workdir/_build
    mkdir -p $workdir/_build

    if [ -f $workdir/autogen.sh ]; then
    (
        echo "building by autotools: $id"
        cd $workdir/_build
        ACLOCAL_PATH="$XORG_PREFIX/share/aclocal:/usr/share/aclocal" ../autogen.sh --prefix="$XORG_PREFIX" $args
        make
        make install
    )
    else
    (
        echo "building by meson: $id"
        cd $workdir/_build
        meson setup -Dprefix="$XORG_PREFIX" $args
        meson compile
        meson install
    )
    fi
    mark_done "$id"
}
