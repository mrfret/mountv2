# rclone docker mount 

# THIS IMAGE IS DEPRECATED.

# INFO

***Deprecated***

```sh
<<- the change to rclone_union was the latest update
```

# V3 is beta stage now

---
## This BRANCHE USED RCLONE_UNION 

THE ENV WILL BE OVERWRITEN !!!

new rclone.env ( old one will be removed and replaced )

```sh
<<-
-------------------------------------------------------
   RCLONE ENVIROMENTS
-------------------------------------------------------
   ## USER VALUES
   PUID                           ${PUID}
   PGID                           ${PGID}
   TIMEZONE                       ${TZ}

   ## RCLONE - SETTINGS
   CACHE_INFO_AGE                 ${CACHE_INFO_AGE}
   POLL_INTERVAL                  ${POLL_INTERVAL}
   DIR_CACHE_TIME                 ${DIR_CACHE_TIME}
   DRIVE_CHUNK_SIZE               ${DRIVE_CHUNK_SIZE}
   UAGENT                         ${UAGENT}
   TPSLIMIT                       ${TPSLIMIT}
   TPSBURST                       ${TPSBURST}

   ## VFS - SETTINGS
   VFS_CACHE_POLL_INTERVAL        ${VFS_CACHE_POLL_INTERVAL}
   VFS_READ_CHUNK_SIZE            ${VFS_READ_CHUNK_SIZE}
   VFS_CACHE_MAX_AGE              ${VFS_CACHE_MAX_AGE}
   VFS_READ_CHUNK_SIZE_LIMIT      ${VFS_READ_CHUNK_SIZE_LIMIT}
   VFS_CACHE_MODE                 ${VFS_CACHE_MODE}
   VFS_CACHE_MAX_SIZE             ${VFS_CACHE_MAX_SIZE}
   VFS_REFRESH                    ${VFS_REFRESH}
   BUFFER_SIZE                    ${BUFFER_SIZE}
   TMPRCLONE                      ${TMPRCLONE}

   ## LOG - SETTINGS 
   LOGLEVEL                       ${LOGLEVEL}
   LOGLEVEL_RC                    ${LOGLEVEL_RC}

   ## RC-CONTROLLE
   RC_ADDRESS                     ${RC_ADDRESS}
   RC_USER                        ${RC_USER}
   RC_PASSWORD                    ${RC_PASSWORD}
```

Docker PRE-CONFIG
```sh
<<-
-------------------------------------------------------
   RCLONE ENVIROMENTS
-------------------------------------------------------
   ## USER VALUES
   PUID                              ${PUID:-911}
   PGID                              ${PGID:-911}
   TIMEZONE                          ${TZ:-UTC}

   ## RCLONE - SETTINGS
   CACHE_INFO_AGE                    ${CACHE_INFO_AGE:-6h}
   POLL_INTERVAL                     ${POLL_INTERVAL:-1m}
   UMASK                             ${UMASK:-022}
   DIR_CACHE_TIME                    ${DIR_CACHE_TIME:-12h}
   DRIVE_CHUNK_SIZE                  ${DRIVE_CHUNK_SIZE:-128M}
   BUFFER_SIZE                       ${BUFFER_SIZE:-32M}
   TMPRCLONE                         ${TMPRCLONE:-/mnt/rclone_cache}
   UAGENT                            ${UAGENT} <<--will random generated
   TPSLIMIT                          ${TPSLIMIT:-10}
   TPSBURST                          ${TPSBURST:-10}

   ## VFS - SETTINGS
   VFS_CACHE_POLL_INTERVAL           ${VFS_CACHE_POLL_INTERVAL:-2m}
   VFS_READ_CHUNK_SIZE               ${VFS_READ_CHUNK_SIZE:-128M}
   VFS_CACHE_MAX_AGE                 ${VFS_CACHE_MAX_AGE:-6h}
   VFS_READ_CHUNK_SIZE_LIMIT         ${VFS_READ_CHUNK_SIZE_LIMIT:-4096M}
   VFS_CACHE_MODE                    ${VFS_CACHE_MODE:-full}
   VFS_CACHE_MAX_SIZE                ${VFS_CACHE_MAX_SIZE}  - ( free space from /mnt  ( size / 4 ) // maximal used ! )
   VFS_REFRESH                       ${VFS_REFRESH:-12h}

   ## LOG - SETTINGS 
   LOGLEVEL                          ${LOGLEVEL:-ERROR}
   LOGLEVEL_RC                       ${LOGLEVEL_RC:-INFO}

   ## RC-CONTROLLE
   RC_ADDRESS                        ${RC_ADDRESS:-5572}
   RC_USER                           ${RC_USER:-rclone}
   RC_PASSWORD                       ${RC_PASSWORD} - ( will random generated )

```

```

----

# THIS IMAGE IS DEPRECATED.

# INFO

***Deprecated***

# V3 is beta stage now
