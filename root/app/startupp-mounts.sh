#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2019, MrDoob
# All rights reserved.
# shellcheck disable=SC2086
function log() {
    echo "[Mount] ${1}"
}
PUID=${PUID:-911}
PGID=${PGID:-911}
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
    chmod -R 775 /config/logs/ && chown -hR abc:abc /config/logs/
    bash ${SMOUNT}/$i-mount.sh
    sleep 1
    echo "mounted" > ${SMOUNT}/$i.mounted
done

sleep 10

/usr/bin/mergerfs -o nonempty,uid=${PUID:-911},gid=${PGID:-911},sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs /mnt/d*\* /mnt/unionfs

MERGERFS_PID=$(pgrep mergerfs)
log "MERGERFS_PID: ${MERGERFS_PID}"

while true; do
  if [ -z "${MERGERFS_PID}" ] || [ ! -e /proc/${MERGERFS_PID} ]; then
     /usr/bin/mergerfs -o nonempty,uid=${PUID:-911},gid=${PGID:-911},sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs /mnt/d*\* /mnt/unionfs
     MERGERFS_PID=$(pgrep mergerfs)
  fi
  sleep 10s
done
#EOF#