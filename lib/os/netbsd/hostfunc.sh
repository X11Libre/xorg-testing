# this file is only included on $HOST_OS_TYPE="freebsd"
host_os_setup() {
    if [ "$HOST_PACKAGES" ]; then
        pkgin -y install $HOST_PACKAGES
    fi
}

host_fetch_tarball() {
    local url="$1"
    local fn="$2"

    mkdir -p "$(dirname "$fn")" 

    if [ ! -f "$fn" ]; then
        echo "fetching tarball: $url"
        ftp -o "$fn.TMP" "$url"
        mv "$fn.TMP" "$fn"
    else
        echo "tarball already present: $fn"
    fi
}
