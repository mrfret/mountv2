######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from doob187                          #
######################################################
FROM ghcr.io/linuxserver/baseimage-alpine:3.13-version-9b18d773
LABEL maintainer=doob187
LABEL org.opencontainers.image.source https://github.com/doob187/mountv2

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add bash bc findutils coreutils && \
  rm -rf /var/cache/apk/*

VOLUME [ "/config" ]

COPY root/ /

EXPOSE 8080

# Setup EntryPoint
ENTRYPOINT [ "/init" ]