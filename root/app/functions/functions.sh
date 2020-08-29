#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob || tHaTer || buGGprint
# All rights reserved.
## function source
function log() {
    echo "[Mount] ${1}"
}

function remove_old_files_start_up() {
# Remove left over webui and transfer files
rm -f /config/logs/* \
      /config/discord/*
}
function bc_start_up_test() {
# Check if BC is installed
BCTEST=/usr/bin/bc
if [ ! -f ${BCTEST} ]; then
   apk --no-cache update -qq && apk --no-cache upgrade -qq && apk --no-cache fix -qq
   apk add bc -qq
   rm -rf /var/cache/apk/*
   log "BC reinstalled"
   if [ "$(echo "10 + 10" | bc)" != "20" ]; then
      log " -> [ WARNING ] BC install  failed [ WARNING ] <-"
      sleep 30
      exit 1
   fi
fi
}
#<|EOF|>#
