#!/bin/bash

set -e
SCRIPT_ROOT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

. $SCRIPT_ROOT_DIR/lib/util.sh

bn=`basename $0`
bn="${bn/vm-enter-/}"

. $SCRIPT_ROOT_DIR/etc/vm/$bn.cf || die "cant find config for $bn"
. $SCRIPT_ROOT_DIR/lib/vm.sh

needvar VM_SSH_PORT

ssh root@localhost -p $VM_SSH_PORT
