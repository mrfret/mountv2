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
while true; do
   MERGERFS_PID=$(pgrep mergerfs)
   if [[ "${MERGERFS_PID}" ]]; then
      restart_container
      break
   else
      sleep 5
      log "waiting for running megerfs"
      continue
  fi
done
}
function restart_container() {
logdocker " -------------------------------"
logdocker " -->    RESTART DOCKER      <---"
logdocker " -->         START          <---"
logdocker " -------------------------------"
apk add docker-cli --quiet --no-cache --force-refresh --no-progress
docker ps -aq --format '{{.Names}}' | sed '/^$/d' > /tmp/dockers
#### LIST SOME DOCKER TO RESTART ####
containers=$(grep -E 'ple|arr|emby|jelly' /tmp/dockers)
for container in $containers; do
    logdocker " -->> Stopping $container <<-- "
    docker stop $container >> /dev/null
done
    logdocker " -->> sleeping 5secs for graceful stopped containers <<--"
    sleep 5
for container in $containers; do
    logdocker " -->> Starting $container <<-- "
    docker start $container >> /dev/null
done
apk del docker-cli --quiet --no-progress && apk del --quiet --clean-protected --no-progress
rm -rf /tmp/dockersrm -rf /tmp/dockers
logdocker " -------------------------------"
logdocker " -->    RESTART DOCKER      <---"
logdocker " -->       FINISHED         <---"
logdocker " -------------------------------"
}

#### END OF FUNCTION #####
log "-> starting mounts part <-"
SMOUNT=/config/scripts
SCHECK=/config/check
SLOG=/config/logs
SRC=/config/rc-refresh
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/://g' | sed '/GDSA/d' | sort -r)
for i in ${mounts[@]}; do
    mkdir -p ${SMOUNT} && chown -hR abc:abc ${SMOUNT} && chmod -R 775 ${SMOUNT}
    mkdir -p ${SRC} && chown -hR abc:abc ${SRC} && chmod -R 775 ${SRC}
    mkdir -p ${SLOG} && chown -hR abc:abc ${SLOG} && chmod -R 775 ${SLOG}
    mkdir -p ${SCHECK} && chown -hR abc:abc ${SCHECK} && chmod -R 775 ${SCHECK}
    if [[ -f "${SMOUNT}/$i-mount.sh" ]]; then
       bash ${SMOUNT}/$i-mount.sh
    fi
    sleep 1
    echo "mounted since $(date)" > ${SCHECK}/$i.mounted
done
sleep 5
UFSPATH=$(cat /tmp/rclone-mount.file)
rm -rf /tmp/mergerfs_mount_file && touch /tmp/mergerfs_mount_file
echo -e "statfs_ignore=nc,nonempty,sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,cache.files=auto-full,category.action=all,category.create=ff,minfreespace=0,fsname=mergerfs" >> /tmp/mergerfs_mount_file
MGFS=$(cat /tmp/mergerfs_mount_file)
log "show the binded mounts with NC-FLAG ${UFSPATH}"
/usr/bin/mergerfs -o ${MGFS} ${UFSPATH}/mnt/downloads=RW /mnt/unionfs
sleep 5
#### CHECK DOCKER.SOCK ####
dockersock=$(curl --silent --output /dev/null --show-error --fail --unix-socket /var/run/docker.sock http://localhost/images/json)
#### RESTART DOCKER #### 
if [[ ${dockersock} != '' ]]; then
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
      sleep 5
      echo "mounted since $(date)" > ${SCHECK}/mergerfs.mounted
      # checkmountstatus
      continue
   else
      sleep 5
      exit 1
  fi
done
