# this file is only included on $HOST_OS_TYPE="freebsd"
host_os_setup() {
    if [ "$HOST_PACKAGES" ]; then
        pkg_add $HOST_PACKAGES
    fi
    ldconfig -R /usr/local/lib
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
