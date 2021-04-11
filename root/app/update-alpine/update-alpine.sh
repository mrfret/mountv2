#!/usr/bin/with-contenv bash
# shellcheck shell=bash
function log() {
echo "[UPDATE] ${1}"
}
# function source start
log "-> update rclone || start <-"
    apk add unzip bash wget --quiet
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -qO rclone.zip && \
    unzip -q rclone.zip && \
    rm -f rclone.zip && \
    mv rclone-*-linux-amd64/rclone /usr/bin/ && \
    rm -rf rclone-**
if [[ $(command -v rclone | wc -l) == "1" ]]; then
    chown -cf abc:abc /root/
fi
log "-> update rclone || done <-"

log "-> update packages || start <-"
    apk --no-cache update --quiet && apk --no-cache upgrade --quiet && apk --no-cache fix --quiet
    apk del --quiet --clean-protected --no-progress
    rm -rf /var/cache/apk/*
log "-> update packages || done <-"
#<EOF>#
