#!/bin/bash -xe
USER=mvold
HOST=pronuntio.web
SOURCE=output/
DEST="${USER}@${HOST}:/var/www/static/appliance/stable/"

rsync -rv "${SOURCE}" "${DEST}"
