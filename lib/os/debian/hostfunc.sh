# this file is only included on $HOST_OS_TYPE="debian"
host_os_setup() {
    sudo apt-get -qq install -y $HOST_PACKAGES
}
