#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
# 
## function source start
while true; do
IFS=$'\n'
filter=$1
## function source end
config=/config/rclone/rclone-docker.conf
mapfile -t mountscrypt < <(eval rclone listremotes --config=${config} | grep "$filter" | grep "$filter" | sed -e 's/tdrive//g' | sed -e 's/gdrive//g' | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d' | sort -r)
## function source end
for i in ${mountscrypt[@]}; do
  echo -e "$(date)\
  $(rclone size $i: --config=${config} --fast-list --user-agent="SomeLegitUserAgent")"  > /config/logs/$i/mountsize-$i.log
done
mapfile -t mountsuncrypt < <(eval rclone listremotes --config=${config} | grep "$filter" | grep "$filter" | sed -e 's/tcrypt//g' | sed -e 's/gcrypt//g' | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d' | sort -r)
for i in ${mountsuncrypt[@]}; do
  echo -e "$(date)\
  $(rclone size $i: --config=${config} --fast-list --exclude="**encrypt**" --user-agent="SomeLegitUserAgent")"  > /config/logs/$i/mountsize-$i.log
done
##sleep for next day##
sleep $(($(date -f - +%s- <<< $'tomorrow 00:30\nnow')0))
done
