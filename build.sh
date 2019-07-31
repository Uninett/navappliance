#!/bin/bash -e
# Builds a virtual appliance in OVF format out of NAV, based on Debian GNU/Linux
# and the latest available NAV Debian package.

NAME=navappliance
TARBALL="output/${NAME}.tar.gz"
PATH=$PATH:/opt/packer
PACKER="$(which packer)"
if [ -z "$PACKER" ]; then
    echo You need to install packer to to build the virtual appliance.
    echo Pleae see http://www.packer.io/
    exit 1
fi

OS=buster
[ -n "$1" ] && OS="$1"

"$PACKER" build "${OS}.json"
tar cvzf "${TARBALL}" "${NAME}/"
gpg --armor --detach-sign "${TARBALL}"
