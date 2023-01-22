######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from doob187                          #
######################################################
FROM ghcr.io/linuxserver/baseimage-alpine:3.17-944c28f6-ls9
LABEL maintainer=doob187
LABEL org.opencontainers.image.source https://github.com/mrfret/mountv2

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add bash bc findutils coreutils && \
  rm -rf /var/cache/apk/*

VOLUME [ "/config" ]

COPY root/ /

EXPOSE 8080

# Setup EntryPoint
ENTRYPOINT [ "/init" ]