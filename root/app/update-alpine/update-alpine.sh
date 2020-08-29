#!/usr/bin/with-contenv bash
# shellcheck shell=bash
function log() {
echo "[Mount] ${1}"
}
## function source start
IFS=$'\n'
filter="$1"
config=/config/rclone-docker.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end
for i in ${mounts[@]}; do
  rclone dedupe skip $i: --config=${config} --drive-use-trash=false --no-traverse --transfers=50 --user-agent="SomeLegitUserAgent" 
  rclone rmdirs $i: --config=${config} --drive-use-trash=false --fast-list --transfers=50 --user-agent="SomeLegitUserAgent" 
  rclone delete $i: --config=${config} --fast-list --drive-trashed-only --drive-use-trash=false --transfers 50 --user-agent="SomeLegitUserAgent" 
  rclone cleanup $i: --config=${config} --user-agent="SomeLegitUserAgent" 
done

log "-> update rclone || start <-"
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O rclone.zip >/dev/null 2>&1 && \
    unzip -qq rclone.zip && rm rclone.zip && \
    mv rclone*/rclone /usr/bin && rm -rf rclone* 
log "-> update rclone || done <-"


log "-> update packages || start <-"
    apk --no-cache update -qq && apk --no-cache upgrade -qq && apk --no-cache fix -qq
    rm -rf /var/cache/apk/*
log "-> update packages || done <-"
