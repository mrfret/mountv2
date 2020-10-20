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
ENV="/config/env/discord.env"
DISCORD_WEBHOOK_URL=$(grep -e "DISCORD_WEBHOOK" "$ENV" | sed "s#DISCORD_WEBHOOK.*=##")
DISCORD_ICON_OVERRIDE=$(grep -e "DISCORD_ICON_OVERRIDE" "$ENV" | sed "s#DISCORD_ICON_OVERRIDE.*=##")
DISCORD_NAME_OVERRIDE=$(grep -e "DISCORD_NAME_OVERRIDE" "$ENV" | sed "s#DISCORD_NAME_OVERRIDE.*=##")
DISCORD_EMBED_TITEL=$(grep -e "DISCORD_EMBED_TITEL" "$ENV" | sed "s#DISCORD_EMBED_TITEL.*=##")
DISCORD="/config/discord/failed.discord"
DISCORD_FOLDER=/config/discord
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end

while true; do
   MERGERFS_PID=$(ps -ef | grep '/usr/bin/mergerfs -o' | head -n 1 | awk '{print $1}')
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
  run=$(ls -la /mnt/drive-$i/ | wc -l)
  pids=$(ps -ef | grep 'rclone mount $i' | head -n 1 | awk '{print $1}')
  if [ "${pids}" ] && [ "$run" != '0' ]; then
     log $i "-> is mounted and works <- [Mount]"
  else
     ENV="/config/env/discord.env"
     DISCORD_WEBHOOK_URL=$(grep -e "DISCORD_WEBHOOK" "$ENV" | sed "s#DISCORD_WEBHOOK.*=##")
     DISCORD_ICON_OVERRIDE=$(grep -e "DISCORD_ICON_OVERRIDE" "$ENV" | sed "s#DISCORD_ICON_OVERRIDE.*=##")
     DISCORD_NAME_OVERRIDE=$(grep -e "DISCORD_NAME_OVERRIDE" "$ENV" | sed "s#DISCORD_NAME_OVERRIDE.*=##")
     DISCORD_EMBED_TITEL=$(grep -e "DISCORD_EMBED_TITEL" "$ENV" | sed "s#DISCORD_EMBED_TITEL.*=##")
     DISCORD="/config/discord/failed.discord"
     if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
        echo -e "[ WARNING] $i FAILED [ WARNING ]" >>"${DISCORD}"
        msg_content=$(cat "${DISCORD}")
        curl -sH "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
     else
         logfailed $i " FAILED [ WARNING ]"
     fi
  fi
 done
 sleep 5
done
#>EOF<#
