# this file is only included on $HOST_OS_TYPE="illumos"
host_os_setup() {
    local retval
    if [ "$HOST_PACKAGES" ]; then
        pkg install --no-refresh $HOST_PACKAGES || retval="$?"
        if [ "$retval" != "" ] && [ "$retval" != 0 ] && [ "$retval" != 4 ]; then
            die "package installation failed: retval=$retval"
        fi
    fi
    log "host OS setup done"
}

host_fetch_tarball() {
    local url="$1"
    local fn="$2"

    mkdir -p "$(dirname "$fn")"

    if [ ! -f "$fn" ]; then
        echo "fetching tarball: $url"
        rm -f "$fn.TMP"
        curl "$url" -o "$fn.TMP"
        mv "$fn.TMP" "$fn"
    else
        echo "tarball already present: $fn"
    fi
}

sudo() {
    echo "Illumos fake sudo: $@"
    eval $@
}
