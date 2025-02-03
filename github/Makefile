IMAGE_TAG := runner1

GITHUB_ORG := X11Libre
GITHUB_TOKEN := $(shell cat $(HOME)/.github-token-xlibre)
XLIBRE_URL := https://github.com/X11Libre

XTESTING_TOKEN := AAALIA5K5BLJHLLBYEUF343HUDBYG
# XTESTING_URL := https://github.com/X11Libre/xorg-testing
XTESTING_URL := https://github.com/X11Libre

VM_PORT := 2022

TOKEN_XLIBRE=

all: image

image:
	docker build . -t $(IMAGE_TAG)
	echo "GITHUB_TOKEN=$(GITHUB_TOKEN)"

runner-xlibre: image
#	docker run -it -e GITHUB_REPO="$(XLIBRE_URL)" -e GITHUB_TOKEN="$(XLIBRE_TOKEN)" -e VM_PORT="$(VM_PORT)" $(IMAGE_TAG)
	docker run -it -e GITHUB_REPO="$(XLIBRE_URL)" -e GITHUB_ORG="$(GITHUB_ORG)" -e GITHUB_TOKEN="$(GITHUB_TOKEN)" -e VM_PORT="$(VM_PORT)" $(IMAGE_TAG)

runner-xtesting: image
#	docker run -it -e GITHUB_REPO="$(XTESTING_URL)" -e GITHUB_TOKEN="$(XTESTING_TOKEN)" -e VM_PORT="$(VM_PORT)" $(IMAGE_TAG)
