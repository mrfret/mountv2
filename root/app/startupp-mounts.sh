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
logdocker " -->    RESTART DOCKER      <---"
logdocker " -->         START          <---"
logdocker " -------------------------------"
apk add docker --quiet --no-cache --force-refresh --no-progress
sleep 3
docker ps -a -q --format '{{.Names}}' | sort -r | sed '/^$/d' > /tmp/dockers
#### LIST SOME DOCKER TO RESTART ####
containers=$(grep -E 'plex|arr|emby' /tmp/dockers)
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
sleep 5
apk del docker --quiet --no-progress && apk del --quiet --clean-protected --no-progress
rm -rf /tmp/dockers
logdocker " -------------------------------"
logdocker " -->    RESTART DOCKER      <---"
logdocker " -->       FINISHED         <---"
logdocker " -------------------------------"
}
function discord_send() {
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
DISCORD="/config/discord/startup.discord"
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}
if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
   echo "[Mount] -> Starting $i Mount $(date) <- [Mount]" >"${DISCORD}"
   msg_content=$(cat "${DISCORD}")
   curl -sH "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
else
   log " Starting $i Mount $(date) <- [Mount]"
fi
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
    log "-> RE - Mounting $i <-"
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
#### END OF FUNCTION #####
log "-> starting mounts part <-"
SMOUNT=/config/scripts
SCHECK=/config/check
SLOG=/config/logs
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d' | sort -r)
for i in ${mounts[@]}; do
    discord_send
    mkdir -p ${SLOG} && mkdir -p ${SCHECK} && mkdir -p ${SMOUNT}
    chmod 775 ${SLOG} && chmod 775 ${SCHECK} && chmod 775 ${SMOUNT}
    chmod 775 ${SCHECK} && chmod 775 ${SCHECK} && chmod 775 ${SCHECK}
    bash ${SMOUNT}/$i-mount.sh
    sleep 1
    echo "mounted since $(date)" > ${SCHECK}/$i.mounted
done
sleep 10
UFSPATH=$(cat /tmp/rclone-mount.file)
rm -rf /tmp/mergerfs_mount_file && touch /tmp/mergerfs_mount_file
echo -e "statfs_ignore=nc,nonempty,sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs" >/tmp/mergerfs_mount_file
MGFS=$(cat /tmp/mergerfs_mount_file)
log "show the binded mounts with NC-FLAG ${UFSPATH}"
/usr/bin/mergerfs -o ${MGFS} ${UFSPATH}/mnt/downloads=RW /mnt/unionfs
sleep 10
#### CHECK DOCKER.SOCK ####
dockersock=$(ls -la /var/run/docker.sock | wc -l)
#### RESTART DOCKER #### 
if [[ ${dockersock} == '1' ]]; then
   startupdocker
else
   sleep 1
   logdocker " [ WARNING ] SOME APPS NEED A RESTART [ WARNING ]"
   logdocker "   SAMPLE :"
   logdocker "   PLEX / SONARR / LIDARR / RADARR / EMBY"
   logdocker " [ WARNING ] SOME APPS NEED A RESTART [ WARNING ]"
   sleep 30
fi
MERGERFS_PID=$(pgrep mergerfs)

log "MERGERFS_PID: ${MERGERFS_PID}"

while true; do
  MERGERFS_PID=$(pgrep mergerfs)
  if [ -z "${MERGERFS_PID}" ] || [ ! -e /proc/${MERGERFS_PID} ]; then
     /usr/bin/mergerfs -o ${MGFS} ${UFSPATH}/mnt/downloads=RW /mnt/unionfs
     startupdocker
     checkmountstatus
  fi
  checkmountstatus
  echo "mounted since $(date)" > ${SCHECK}/mergerfs.mounted
  sleep 10
done
