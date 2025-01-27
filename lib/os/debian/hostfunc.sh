# this file is only included on $HOST_OS_TYPE="debian"
host_os_setup() {
    needvar HOST_SCHROOT_PACKAGES
    sudo apt-get -qq install -y $HOST_SCHROOT_PACKAGES
}
