#!/bin/bash

set -e

die() {
    echo "$0: $@" >&2
    exit 1
}

[ "$GITHUB_REPO" ] || die "missing repo url"
[ "$GITHUB_TOKEN" ] || die "missing token"
[ "$VM_PORT" ] || die "missing VM port"

cd /home/github_runner

./config.sh --unattended --url "$GITHUB_REPO" --token "$GITHUB_TOKEN"
./run.sh
