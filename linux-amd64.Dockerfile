################################
# All rights reserved.         #
# started from Zero            #
# Docker owned from sudobox.io #
################################
FROM sudobox/docker-images:amd64-alpine
LABEL Maintainer="sudobox.io" \
      Description="Container incl rclone/mergerfs and auto mounting drives."

COPY root/ /

VOLUME [ "/config" ]
RUN chown 911:911 /config && \
    addgroup -g 911 abc && \
    adduser -u 911 -D -G abc abc

EXPOSE 8080
# Setup EntryPoint
ENTRYPOINT [ "/init" ]
