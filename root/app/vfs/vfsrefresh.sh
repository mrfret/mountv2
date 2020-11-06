#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
#
# ## function source start
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006
source /config/env/rclone.env
if [[ $(grep -e 'VFS_REFRESH' /config/env/rclone.env | wc -l) != 1 ]]; then
   VFS_REFRESH=${VFS_REFRESH:-48h}
else
   VFS_REFRESH=${VFS_REFRESH}
fi

function drivecheck() {
while true; do
  MERGERFS_PID=$(pgrep mergerfs)
  if [ "${MERGERFS_PID}" ]; then
      sleep 5 && continue
   else
      break && sleep 5
  fi
done
SRC=/config/rc-refresh
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/://g' | sed '/GDSA/d' | sort -r)
for i in ${mounts[@]}; do
  run=$(ls -la /mnt/drive-$i/ | wc -l)
  pids=$(ps -ef | grep 'rclone mount $i' | head -n 1 | awk '{print $1}')
  if [ "$pids" != '0' ] && [ "$run" != '0' ]; then
     /bin/bash ${SRC}/$i-rc-file.sh && chmod a+x ${SRC}/$i-rc-file.sh && chown -hR abc:abc ${SRC}/$i-rc-file.sh
     truncate -s 0 /config/logs/*.log
     sleep 5
  else
     sleep 30
  fi
done
}
while true; do
   if [[ ${VFS_REFRESH} != '0' ]]; then
      drivecheck && sleep ${VFS_REFRESH}
   else
      break && sleep ${VFS_REFRESH}
   fi
done
#UI addon *?*
#<EOF>#
