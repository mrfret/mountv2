#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
#
# ## function source start
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006
ENV="/config/env/rclone.env"
VFS_REFRESH=$(grep -e "VFS_REFRESH" "$ENV" | sed "s#.*=##")

function drivecheck() {
while true; do
  MERGERFS_PID=$(pgrep mergerfs)
  if [ ! "${MERGERFS_PID}" ]; then
      sleep 5 && continue
   else
      break
  fi
done
SRP=/config/rc-purge
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/://g' | sed '/GDSA/d' | sort -r)
for i in ${mounts[@]}; do
  run=$(ls -la /mnt/drive-$i/ | wc -l)
  pids=$(ps -ef | grep 'rclone mount $i' | head -n 1 | awk '{print $1}')
  if [ "$pids" != '0' ] && [ "$run" != '0' ]; then
     /bin/bash ${SRP}/$i-rc-file.sh && chmod a+x ${SRP}/$i-rc-file.sh && chown -hR abc:abc ${SRP}/$i-rc-file.sh
     truncate -s 0 /config/logs/*.log
     sleep 5
  else
     sleep 60
  fi
done
}
while true; do
   if [[ ! "${VFS_REFRESH}" ]]; then
     break
   else
     drivecheck && sleep "${VFS_REFRESH}"
   fi
done
