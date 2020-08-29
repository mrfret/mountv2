#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# cleanup remotes based of rclone.conf file
# only clean remotes thats inside the rclone.conf
function log() {
    echo "[Mount] ${1}"
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
  command_running=$(ls -l /mnt/drive-$i/ | awk '$1 == "total" {print $2}')
  if [ "$command_running" == '0' ]; then
     log second check for running $i;
     command_exist_pid=/config/pid/$i
     if [  -f "$command_exist_pid" ]; then
         command_test_pid=$(cat /config/pid/$i)
         if [ "$command_test_pid" != $i ]; then
          log Mount down $i;
         fi
     else
         log $i not mounted or failed;
     fi
  fi
 done
 sleep 3
done
#>EOF<#