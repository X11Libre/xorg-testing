#!/bin/bash

set -e

die() {
    echo "$0: $@" >&2
    exit 1
}

[ "$GITHUB_REPO"   ] || die "missing repo url"
[ "$GITHUB_TOKEN"  ] || die "missing token"
[ "$GITHUB_ORG"    ] || die "missing organisation"
[ "$GITHUB_LABELS" ] || die "missing GITHUB_LABELS"
[ "$VM_SSH_PORT"   ] || die "missing VM_SSH_PORT"

cd /home/github_runner

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/registration-token | jq .token --raw-output)

./config.sh --unattended --url "$GITHUB_REPO" --token "$REG_TOKEN" --labels "$GITHUB_LABELS"
./run.sh
