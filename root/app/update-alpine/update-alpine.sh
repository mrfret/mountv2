#!/usr/bin/with-contenv bash
# shellcheck shell=bash
function log() {
echo "[Mount] ${1}"
}
## function source start
IFS=$'\n'
filter="$1"
config=/config/rclone/rclone-docker.conf
#rclone listremotes | gawk "$filter"
mapfile -t mounts < <(eval rclone listremotes --config=${config} | grep "$filter" | sed -e 's/tcrypt://g' | sed -e 's/gcrypt://g' | sed -e 's/[GDSA00-99C:]//g' | sed '/^$/d')
## function source end
for i in ${mounts[@]}; do
  rclone dedupe skip $i: --config=${config} --drive-use-trash=false --no-traverse --transfers=50 --user-agent="SomeLegitUserAgent" 
  rclone rmdirs $i: --config=${config} --drive-use-trash=false --fast-list --transfers=50 --user-agent="SomeLegitUserAgent" 
  rclone delete $i: --config=${config} --fast-list --drive-trashed-only --drive-use-trash=false --transfers 50 --user-agent="SomeLegitUserAgent" 
  rclone cleanup $i: --config=${config} --user-agent="SomeLegitUserAgent" 
done
log "-> update rclone || start <-"
    apk add unzip --quiet
    curl --no-progress-meter https://rclone.org/install.sh | bash -s beta >/dev/null 2>&1
log "-> update rclone || done <-"

log "-> update packages || start <-"
    apk --no-cache update --quiet && apk --no-cache upgrade --quiet && apk --no-cache fix --quiet
    apk del --quiet --clean-protected --no-progress
    rm -rf /var/cache/apk/*
log "-> update packages || done <-"
#<EOF>#