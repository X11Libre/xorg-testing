# X.org testing ground

A little toolkit to help in testing X.org Xserver

## Getting started

This little toolkit aims helping building and testing Xorg in a jail.

As for now *(as host as well as jail)* only Debian-based distros supported,
for jailing just schroot. But much more planned for the future.

The idea is giving testers a tool for installing latest Xorg directly 
from git heads, so they don't need to do this manually, anymore.

For the future also planned adding test cases that can be run automatically.
Possibly also test cycle automation *(eg. via labgrid)*, so one doesn't even
need to manually log on individual DUTs anymore.

## Configuration

* all configs residing under [`./etc`](etc) subdirectory
* some site specific things can be configured in [`etc/site.cf`](etc/site.cf)
* [`etc/hosts/`](etc/hosts) there's one config per host type *(as used in $HOST_OS in [`site.cf`](etc/site.cf))*
* [`etc/targets/`](etc/targets) there's one config per target type *(as used in $TARGET_ID in [`site.cf`](etc/site.cf))*

## Running

* currently just building basic Xserver: placed under `/usr/local`
* call [`build-tesing-jail`](build-testing-jail) for that
* NOTE: this will automatically install few host packages *(schroot, mdebootstrap, ...)*
* NOTE: if started as non-root, it will ask for password *(sudo)*

## Troubleshooting

* in worst case the chroot can always be removed *(`/srv/chroots/xorg-testing/<TARGET_ID>`)*
* forcing re-clone and rebuild: remove the git clone *(in jail, under `/srv/xorg-testing/...`)* as well as the corresponding `*.DONE` file

## Project status

It's all pretty early yet. If you encounter any problems or like to have enhancements,
feel free to submit bug reports or pull requests.

## Author & Contact

Enrico Weigelt, metux IT consult <info@metux.net>
