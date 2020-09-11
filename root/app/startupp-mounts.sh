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
SERVICE=$(pgrep mergerfs | wc -l)
LSFOLDER=$(ls /mnt/unionfs | wc -l)
if [[ ${SERVICE} -ne "0" && ${LSFOLDER} -ne "0" ]]; then
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
docker ps -a -q --format '{{.Names}}' | sort -r | sed -e 's/oauth//g' | sed -e 's/portainer//g' | sed -e 's/traefik//g' | sed -e 's/mounts//g' | sed '/^$/d' > /tmp/dockers
#### LIST SOME DOCKER TO RESTART ####
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
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
#### function source end
function discord_send() {
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}
if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
   echo "[Mount] -> Starting $i Mount  $(date) <- [Mount]" >"${DISCORD}"
   msg_content=$(cat "${DISCORD}")
   curl -sH "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
else
   log " Starting $i Mount  $(date) <- [Mount]"
fi
}
log "-> starting mounts part <-"
SMOUNT=/config/scripts
SCHECK=/config/check
SLOG=/config/logs
function fcreate() {
mkdir -p "${1}"
}
function fown() {
chmod 775 "${1}"
}
function fmod() {
chown -hR abc:abc "${1}"
}
function checkmountstatus() {
SCHECK=/config/check
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d' | sort -r)
for i in ${mounts[@]}; do
if [ -z $(pgrep -f $i | head -n 1) ] || [ ! -e /proc/$(pgrep -f $i | head -n 1) ]; then
    fusermount -uz /mnt/drive-$i >>/dev/null
    fusermount -uz /mnt/unionfs >>/dev/null
    log "-> REMounting $i <-"
    bash ${SMOUNT}/$i-mount.sh
    sleep 1
    echo "remounted since $(date)" > ${SCHECK}/$i.mounted
    startupdocker
  else
    truncate -s 2 ${SCHECK}/$i.mounted
    echo "last check $(date)" > ${SCHECK}/$i.mounted
  fi
done
}

for i in ${mounts[@]}; do
    discord_send
    fcreate ${SLOG}; fcreate ${SCHECK}; fcreate ${SMOUNT}
    fown ${SLOG}; fown ${SCHECK}; fown ${SMOUNT}
    fown ${SCHECK}; fown ${SCHECK}; fown ${SCHECK}
    bash ${SMOUNT}/$i-mount.sh
    sleep 1
    echo "mounted since $(date)" > ${SCHECK}/$i.mounted
done
sleep 10
UFSPATH=$(cat /tmp/rclone-mount.file)
log "read ${UFSPATH} to see the remote binded mounts"

/usr/bin/mergerfs -o nonempty,statfs_ignore=nc,sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs ${UFSPATH}/mnt/downloads=RW /mnt/unionfs
#### CHECK DOCKER.SOCK ####
dockesock=$(ls -la /var/run/docker.sock | wc -l)
#### RESTART DOCKER #### 
if [[ ${dockesock} == '1' ]]; then
   startupdocker
else
   sleep 1
   logdocker " [ WARNING ] SOME APPS NEED A RESTART [ WARNING ]"
   logdocker "   SAMPLE :"
   logdocker "   Plex / Sonarr / LIDARR / RADARR / EMBY"
   logdocker " [ WARNING ] SOME APPS NEED A RESTART [ WARNING ]"
   sleep 30
fi
MERGERFS_PID=$(pgrep mergerfs)
log "MERGERFS_PID: ${MERGERFS_PID}"
while true; do
  if [ -z "${MERGERFS_PID}" ] || [ ! -e /proc/${MERGERFS_PID} ]; then
     /usr/bin/mergerfs -o nonempty,statfs_ignore=nc,sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs ${UFSPATH}/mnt/downloads=RW /mnt/unionfs
     MERGERFS_PID=$(pgrep mergerfs)
     startupdocker
     checkmountstatus
  fi
  checkmountstatus
  echo "mounted since $(date)" > ${SCHECK}/mergerfs.mounted
  sleep 10
done
