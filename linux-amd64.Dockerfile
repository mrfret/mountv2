######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from sudobox.io                       #
######################################################
FROM lsiobase/alpine:3.12
LABEL maintainer=sudobox.io

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add shadow linux-headers musl \
  bash bc findutils coreutils && \
  rm -rf /var/cache/apk/*

VOLUME [ "/config" ]

COPY root/ /

EXPOSE 8080

HEALTHCHECK --timeout=5s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
# Setup EntryPoint
ENTRYPOINT [ "/init" ]
