#!/bin/bash

set -e

die() {
    echo "$0: $@" >&2
    exit 1
}

[ "$GITHUB_REPO" ] || die "missing repo url"
[ "$GITHUB_TOKEN" ] || die "missing token"
[ "$VM_PORT" ] || die "missing VM port"
[ "$GITHUB_ORG" ] || die "missing organisation"

cd /home/github_runner

curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/registration-token

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/registration-token | jq .token --raw-output)
echo "REG_TOKEN=$REG_TOKEN"

./config.sh --unattended --url "$GITHUB_REPO" --token "$REG_TOKEN"
./run.sh
