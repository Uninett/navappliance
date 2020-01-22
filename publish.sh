#!/bin/bash -xe
USER=mvold
HOST=moriens.web.uninett.no
SOURCE=output/
DEST="${USER}@${HOST}:/var/www/static/appliance/stable/"

rsync -rv "${SOURCE}" "${DEST}"
