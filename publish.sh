#!/bin/bash -xe
USER=root
HOST=pronuntio
SOURCE=output/
DEST="${USER}@${HOST}:/var/www/static/appliance/stable/"

rsync -rv "${SOURCE}" "${DEST}"
