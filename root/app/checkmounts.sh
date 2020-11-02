#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# cleanup remotes based of rclone.conf file
# only clean remotes thats inside the rclone.conf
function log() {
    echo "[Mount] ${1} ${2}"
}
function logfailed() {
    echo "[Mount] [FAILED] ${1} ${2}"
}
## function source start
SMOUNT=/config/scripts
SCHECK=/config/check
ENV="/config/env/discord.env"
DISCORD_WEBHOOK_URL=$(grep -e "DISCORD_WEBHOOK_URL" "$ENV" | sed "s#.*=##")
DISCORD_ICON_OVERRIDE=$(grep -e "DISCORD_ICON_OVERRIDE" "$ENV" | sed "s#.*=##")
DISCORD_NAME_OVERRIDE=$(grep -e "DISCORD_NAME_OVERRIDE" "$ENV" | sed "s#.*=##")
DISCORD_EMBED_TITEL=$(grep -e "DISCORD_EMBED_TITEL" "$ENV" | sed "s#.*=##")
DISCORDFAIL="/config/discord/failed.discord"
DISCORDSTART="/config/discord/startup.discord"
## function source end
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/://g' | sed '/GDSA/d')
for i in ${mounts[@]}; do
  if [ "$(pgrep -f $i | head -n 1)" ] && [ -e /proc/$(pgrep -f $i | head -n 1) ]; then
     sleep 2 && break
  else
     if [ "${DISCORD_WEBHOOK_URL}" != 'null' ]; then
        echo "[Mount] -> Started $i Mount $(date) <- [Mount]" >"${DISCORDSTART}"
        msg_content=$(cat "${DISCORDSTART}")
        curl -sH "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${DISCORD_EMBED_TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
     else
        log " Starting $i Mount $(date) <- [Mount]"
     fi
  fi
done

while true; do
   MERGERFS_PID=$(pgrep mergerfs)
   if [[ "${MERGERFS_PID}" ]]; then
      break
   else
      sleep 5
      log "waiting for running megerfs"
      continue
  fi
done

while true; do
  for i in ${mounts[@]}; do
    RCLONE_CHECK=$(rclone lsf $i:/.mountcheck-$i --config=${config} | wc -l)
    MOUNT_CHECK=$(ls -la /mnt/drive-$i/.mountcheck-$i | wc -l)
    if [ $(pgrep -f $i | head -n 1) ] && [ -e /proc/$(pgrep -f $i | head -n 1) ] && [ ${RCLONE_CHECK} == ${MOUNT_CHECK} ]; then
       log $i "-> is mounted and works <- [Mount]"
       truncate -s 2 ${SCHECK}/$i.mounted
       echo "last check $(date)" > ${SCHECK}/$i.mounted
    else
       if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
          echo -e "[ WARNING] $i FAILED REMOUNT STARTS NOW [ WARNING ]" >>"${DISCORDFAIL}"
          msg_content=$(cat "${DISCORDFAIL}")
          curl -sH "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${DISCORD_EMBED_TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
       else
          logfailed $i " FAILED REMOUNT STARTS NOW [ WARNING ]"
       fi
       fusermount -uz /mnt/drive-$i >>/dev/null
       log "-> RE - Mounting $i <-"
       bash ${SMOUNT}/$i-mount.sh
       echo "remounted since $(date)" > ${SCHECK}/$i.mounted
    fi
  done
  sleep 60
done
#>EOF<#
