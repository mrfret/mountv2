#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# shellcheck disable=SC2086
# shellcheck disable=SC2006
function log() {
    echo "[Mount] ${1}"
}
function logdocker() {
    echo "[DOCKER] ${1}"
}
function startupdocker() {
while true; do
   MERGERFS_PID=$(pgrep mergerfs)
   if [[ "${MERGERFS_PID}" ]]; then
      restart_container
      break
   else
      sleep 5 && log "waiting for running megerfs"
      continue
  fi
done
}
function crashed() {
logdocker " -------------------------------"
logdocker " -->      STOP DOCKERS      <---"
logdocker " -->    MERGERFS CRASHED    <---"
logdocker " -------------------------------"
container=$(docker ps -aq --format '{{.Names}}' | sed '/^$/d' | grep -E 'ple|arr|emby|jelly')
docker stop $container >> /dev/null
sleep 2
}
function restart_container() {
logdocker " -------------------------------"
logdocker " -->   RESTART DOCKER PART  <---"
logdocker " -->         STARTED        <---"
logdocker " -------------------------------"
container=$(docker ps -aq --format '{{.Names}}' | sed '/^$/d' | grep -E 'ple|arr|emby|jelly')
docker stop $container >> /dev/null
logdocker " -->> sleeping 5secs for graceful stopped containers <<--"
sleep 5
container=$(docker ps -aq --format '{{.Names}}' | sed '/^$/d' | grep -E 'ple|arr|emby|jelly')
#### LIST SOME DOCKER TO RESTART ####
docker start $container >> /dev/null
logdocker " -------------------------------"
logdocker " -->   RESTART DOCKER PART  <---"
logdocker " -->        FINISHED        <---"
logdocker " -------------------------------"
}
#### END OF FUNCTION #####
apk add docker-cli --quiet --no-cache --force-refresh --no-progress
log "-> starting mounts part <-"
SMOUNT=/config/scripts
SCHECK=/config/check
SLOG=/config/logs
SRC=/config/rc-refresh
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
if [[ -d ${SLOG} ]];then rm -rf ${SLOG};fi
mkdir -p ${SMOUNT} && chown -hR abc:abc ${SMOUNT} && chmod -R 775 ${SMOUNT}
mkdir -p ${SRC} && chown -hR abc:abc ${SRC} && chmod -R 775 ${SRC}
mkdir -p ${SCHECK} && chown -hR abc:abc ${SCHECK} && chmod -R 775 ${SCHECK}
if [[ -f "${SMOUNT}/union-mount.sh" ]];then
   if [[ ! -d ${SLOG} ]];then mkdir -p ${SLOG};fi
   if [[ ! -f  "${SLOG}/rclone-union.log" ]];then touch ${SLOG}/rclone-union.log;fi
   bash ${SMOUNT}/union-mount.sh
   echo "rclone_union is mounted since $(date)"
fi
sleep 5
UFSPATH=$(cat /tmp/rclone-mount.file)
rm -rf /tmp/mergerfs_mount_file && touch /tmp/mergerfs_mount_file
echo -e "allow_other,rw,statfs_ignore=nc,async_read=false,use_ino,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true,nonempty,minfreespace=0,fsname=mergerfs" >> /tmp/mergerfs_mount_file
MGFS=$(cat /tmp/mergerfs_mount_file)
mergerfs -o ${MGFS} ${UFSPATH} /mnt/unionfs
sleep 5
### remove old check files ( not needed anymore )
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/://g' | sed '/remote/d' | sed '/GDSA/d')
for i in ${mounts[@]}; do
    rm -rf /mnt/unionfs/.mountcheck-$i
done
###
#### CHECK DOCKER.SOCK ####
dockersock=$(curl --silent --output /dev/null --show-error --fail --unix-socket /var/run/docker.sock http://localhost/images/json)
#### RESTART DOCKER #### 
if [[ "${dockersock}" != '' ]]; then
   sleep 1
   logdocker " [ WARNING ] SOME APPS NEED A RESTART [ WARNING ]"
   logdocker "   SAMPLE :"
   logdocker "   PLEX / SONARR / LIDARR / RADARR / EMBY"
   logdocker " [ WARNING ] SOME APPS NEED A RESTART [ WARNING ]"
   sleep 30
else
   startupdocker
fi

MERGERFS_PID=$(pgrep mergerfs)

log "MERGERFS PID: ${MERGERFS_PID}"

while true; do
   MERGERFS_PID=$(pgrep mergerfs)
   if [ "${MERGERFS_PID}" ] && [ -e /proc/${MERGERFS_PID} ]; then
      sleep 5 && echo "mounted since $(date)"
      continue
   else
      sleep 5 && crashed
      exit 0
  fi
done
#EOF#