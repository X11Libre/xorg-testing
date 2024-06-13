# this file is only included on $HOST_OS_TYPE="freebsd"
host_os_setup() {
    needvar HOST_PORTS_REPO HOST_PORTS_REF
    if [ "$HOST_PACKAGES" ]; then
        pkg install -y $HOST_PACKAGES
    fi
}

host_fetch_tarball() {
    local url="$1"
    local fn="$2"

    mkdir -p "$(dirname "$fn")"

    if [ ! -f "$fn" ]; then
        echo "fetching tarball: $url"
        rm -f "$fn.TMP"
        fetch "$url" -o "$fn.TMP"
        mv "$fn.TMP" "$fn"
    else
        echo "tarball already present: $fn"
    fi
}
