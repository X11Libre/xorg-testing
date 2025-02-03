IMAGE_TAG := xlibre-runner-hosted

GITHUB_ORG := X11Libre
GITHUB_TOKEN := $(shell cat $(HOME)/.github-token-xlibre)
GITHUB_URL := https://github.com/$(GITHUB_ORG)
GITHUB_LABELS := vm-freebsd-14.2-amd64

VM_SSH_PORT := 2022

all: image

image:
	docker build . -t $(IMAGE_TAG)

runner-xlibre: image
	docker run -it --rm \
            -e GITHUB_REPO="$(GITHUB_URL)" \
            -e GITHUB_ORG="$(GITHUB_ORG)" \
            -e GITHUB_TOKEN="$(GITHUB_TOKEN)" \
            -e GITHUB_LABELS="$(GITHUB_LABELS)" \
            -e VM_SSH_PORT="$(VM_SSH_PORT)" \
            $(IMAGE_TAG)
