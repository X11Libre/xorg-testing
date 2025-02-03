#!/bin/bash

set -e
SCRIPT_ROOT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

. $SCRIPT_ROOT_DIR/lib/util.sh

IMAGE_TAG="xlibre-runner-hosted-proxy"

CFNAME=`basename $0`
CFNAME="${CFNAME/gitlab-runner-/}"

. $SCRIPT_ROOT_DIR/etc/vm/$CFNAME.cf || die "cant find config for $bn"
. $SCRIPT_ROOT_DIR/lib/vm.sh

GITHUB_LABELS="vm-$CFNAME"

( cd github && docker build . -t $IMAGE_TAG )

GITHUB_ORG=X11Libre
GITHUB_TOKEN=$(cat $HOME/.github-token-xlibre)
GITHUB_URL=https://github.com/$GITHUB_ORG

docker run -it --rm \
    -e GITHUB_REPO="$GITHUB_URL" \
    -e GITHUB_ORG="$GITHUB_ORG" \
    -e GITHUB_TOKEN="$GITHUB_TOKEN" \
    -e GITHUB_LABELS="$GITHUB_LABELS" \
    -e VM_PORT="$VM_SSH_PORT" \
    $IMAGE_TAG
