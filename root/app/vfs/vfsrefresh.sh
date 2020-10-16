#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# 
# ## function source start

VFS_REFRESH=${VFS_REFRESH}

function refresh() {
SRC=/config/rc-refresh
SCACHE=/tmp/rclone_cache
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
##### RUN MOUNT #####
for i in ${mounts[@]}; do
  bash ${SRC}/$i-rc-file.sh
  chmod a+x ${SRC}/$i-rc-file.sh
  chown -hR abc:abc ${SRC}/$i-rc-file.sh
  sleep 5
done
}

function checkmergerfs() {
MERGERFS_PID=$(pgrep mergerfs)
if [ -z "${MERGERFS_PID}" ]; then
    sleep 5
    checkmergerfs
fi
}

function drivecheck() {

checkmergerfs

IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
for i in ${mounts[@]}; do
  run=$(ls /mnt/drive-$i/ | wc -l)
  pids="$(ps -ef | grep '$i-mount.sh' | head -n 1 | grep -v grep | awk '{print $1}' | wc -l)"
  if [[ "$run" != "0" && "$pids" != "0" ]]; then
     sleep 30
  else
     refresh
  fi
done
}

while true; do

if [[ "$( ${VFS_REFRESH} | sed -e 's/h//g')" != 'null' ]]; then
   drivecheck
   sleep ${VFS_REFRESH}
fi
done
#UI addon *?*
#<EOF>#
