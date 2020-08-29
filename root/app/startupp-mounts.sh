#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Copyright (c) 2019, MrDoob
# All rights reserved.

# shellcheck disable=SC2086
function log() {
    echo "[Mount] ${1}"
}
IFS=$'\n'
filter="$1"
config=/config/rclone.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end

log "-> starting mounts part <-"
SMOUNT=/config/scripts
for i in ${mounts[@]}; do
    log "-> Mounting $i <-"
    bash ${SMOUNT}/$i-mount.sh
	sleep 1
    log $i ${SMOUNT}/$i.mounted
done

