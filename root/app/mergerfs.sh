#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Copyright (c) 2019, PhysK
# All rights reserved.

# shellcheck disable=SC2086

/usr/bin/mergerfs -o sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs /mnt/drive-*\ /mnt/unionfs

MERGERFS_PID=$(pgrep mergerfs)
log "PID: ${MERGERFS_PID}"

while true; do

  if [ -z "${MERGERFS_PID}" ] || [ ! -e /proc/${MERGERFS_PID} ]; then
     fusermount -uz  /mnt/unionfs
    /usr/bin/mergerfs -o sync_read,auto_cache,dropcacheonclose=true,use_ino,allow_other,func.getattr=newest,category.create=ff,minfreespace=0,fsname=mergerfs /mnt/drive-*\ /mnt/unionfs
    MERGERFS_PID=$(pgrep mergerfs)
  fi
  sleep 10s
done
