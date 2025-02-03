#!/bin/bash

set -e
SCRIPT_ROOT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

. $SCRIPT_ROOT_DIR/lib/util.sh

bn=`basename $0`
bn="${bn/vm-buildjob-/}"

. $SCRIPT_ROOT_DIR/etc/vm/$bn.cf || die "cant find config for $bn"
. $SCRIPT_ROOT_DIR/lib/vm.sh

boot_and_wait_for_vm
vm_build_testing_jail

#needvar VM_SSH_PORT
# ssh root@localhost -p $VM_SSH_PORT
