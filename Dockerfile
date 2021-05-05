######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from doob187                          #
######################################################
FROM ghcr.io/linuxserver/baseimage-alpine:latest
LABEL maintainer=doob187
LABEL org.opencontainers.image.source https://github.com/doob187/mountv2

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add wget unzip shadow linux-headers musl \
  bash bc findutils coreutils && \
  rm -rf /var/cache/apk/*

RUN \
  wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -qO rclone.zip && \
  unzip -q rclone.zip && \
  rm -f rclone.zip && \
  mv rclone-*-linux-amd64/rclone /usr/bin/ && \
  rm -rf rclone-**

VOLUME [ "/config" ]

COPY root/ /

EXPOSE 8080

# Setup EntryPoint
ENTRYPOINT [ "/init" ]
