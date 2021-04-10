######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from doob187                          #
######################################################
FROM lsiobase/alpine:3.13
LABEL maintainer=sudobox.io

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add shadow linux-headers musl \
  bash bc findutils coreutils && \
  rm -rf /var/cache/apk/*

VOLUME [ "/config" ]

COPY root/ /

EXPOSE 8080

# Setup EntryPoint
ENTRYPOINT [ "/init" ]
