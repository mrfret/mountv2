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
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}
DISCORD="/config/discord/failed.discord"
IFS=$'\n'
filter="$1"
config=/config/rclone.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end
sleep 60
while true; do
 for i in ${mounts[@]}; do
  command_running=$(ls /mnt/drive-$i/ | wc -l)
  if [ "$command_running" == '0' ]; then
     log "-> second check of running mount [Mount] <-" $i;
     command_exist_pid=/config/scripts/$i.mounted
     if [ -f "$command_exist_pid" ]; then
          command_exist_pid=/config/scripts/$i.mounted
         if [ ! -f "$command_exist_pid" ]; then
            DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
            DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
            DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}
            DISCORD="/config/discord/failed.discord"
            if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
               echo $i "[ WARNING] Mounts FAILED or DOWN [ WARNING ]" >"${DISCORD}"
               msg_content=$(cat "${DISCORD}")
               curl -sH "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
            else
               logfailed $i " not mounted or failed <- [Mount] ";
            fi
         fi
     else
         logfailed $i " not mounted or failed <- [Mount] ";
     fi
  else
     log $i "-> is mounted and works <- [Mount]";
  fi
 done
 sleep 5
done
#>EOF<#