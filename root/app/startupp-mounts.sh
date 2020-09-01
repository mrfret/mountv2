#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2019, MrDoob
# All rights reserved.
# shellcheck disable=SC2086
function log() {
    echo "[Mount] ${1}"
}
function logdocker() {
echo "[DOCKER] ${1}"
}
function startupdocker() {
SERVICE=(pgrep -x mergerfs)
LSFOLDER=$(ls /mnt/unionfs/ | wc -l)
if [[ -z ${SERVICE} && ${LSFOLDER} != '0' ]]; then
   restart_container
else
   wait_for
fi
}
function wait_for() {
  logdocker " -> wait for mounted drives <- "
  sleep 5
  startupdocker
}
function restart_container() {
logdocker " -------------------------------"
logdocker " -->    INSTALL DOCKER      <---"
logdocker " -------------------------------"
apk add docker --quiet --no-cache --force-refresh --no-progress
sleep 3
docker ps -a -q --format '{{.Names}}' | sort | sed -e 's/oauth//g' | sed -e 's/portainer//g' | sed -e 's/traefik//g' | sed -e 's/mounts//g' | sed '/^$/d' > /tmp/dockers
# docker restart plex sonarr radarr sonarr sonarr4k radarr4k radarrhdr sonarrhdr emby >> /dev/null
containers=$(grep -E 'plex|arr|emby' /tmp/dockers)
for container in $containers; do
    logdocker " -->> Stopping $container <<-- "
    docker stop $container >> /dev/null
done
logdocker " --> sleeping 5secs for graceful stopped containers <--"
sleep 5
for container in $containers; do
    logdocker " -->> Starting $container <<-- "
    docker start $container >> /dev/null
done
sleep 5
apk del docker --quiet --no-progress && apk del --quiet --clean-protected --no-progress
logdocker " -------------------------------"
logdocker " -->  restart dockers done  <<--"
logdocker " -->  purge docker install  <<--"
logdocker " -------------------------------"
}
PUID=${PUID}
PGID=${PGID}
IFS=$'\n'
filter="$1"
config=/config/rclone-docker.conf
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

/usr/bin/mergerfs -o nonempty,sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs /mnt/d*\* /mnt/unionfs
## restart docker 
startupdocker
###
MERGERFS_PID=$(pgrep mergerfs)
log "MERGERFS_PID: ${MERGERFS_PID}"

while true; do
  if [ -z "${MERGERFS_PID}" ] || [ ! -e /proc/${MERGERFS_PID} ]; then
     /usr/bin/mergerfs -o nonempty,sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs /mnt/d*\* /mnt/unionfs
     MERGERFS_PID=$(pgrep mergerfs)
     startupdocker
  fi
  sleep 10s
done
#EOF#
