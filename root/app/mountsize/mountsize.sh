#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# 
## function source start
IFS=$'\n'
filter=$1
## function source end
config=/config/rclone-docker.conf
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end
for i in ${mounts[@]}; do
  echo; echo For $i | tee -a /config/logs/rclone-$i.log
  rclone size $i: --config=${config} --fast-list | tee -a /config/logs/mountsize-$i.log
done
