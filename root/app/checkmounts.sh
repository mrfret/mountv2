#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# cleanup remotes based of rclone.conf file
# only clean remotes thats inside the rclone.conf
function log() {
    echo "[Mount] ${1} ${2}"
}
## function source start
IFS=$'\n'
filter="$1"
config=/config/rclone.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end
while true; do
 for i in ${mounts[@]}; do
  command_running=$(ls /mnt/drive-$i/ | wc -l)
  if [ "$command_running" == '0' ]; then
     log "-> second check of running mount [Mount] <-" $i;
     command_exist_pid=/config/scripts/$i.mounted
     if [  -f "$command_exist_pid" ]; then
         command_test_pid=$(cat /config/pid/$i)
         if [ "$command_test_pid" != $i ]; then
          log " -> Mount down <- [Mount]" $i;
         fi
     else
         log $i " mounted or failed <- [Mount] ";
     fi
   else
        log $i "-> mounted <- [Mount]";
  fi
 done
 sleep 5
done
#>EOF<#