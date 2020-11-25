######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from sudobox.io                       #
######################################################
FROM sudobox/docker-images:arm64v8-alpine
LABEL Maintainer="sudobox.io" \
      Description="Container for Basic UI"

COPY root/ /

RUN \
 echo "**** install build packages ****" && \
 apk --quiet --no-cache --no-progress add \
        ca-certificates libattr logrotate shadow bash bc findutils coreutils openssl \
        autoconf automake libtool gettext-dev attr-dev linux-headers musl \
        curl libxml2-utils openntpd grep tar && \
        rm -rf /var/cache/apk/*

RUN \
  echo "**** Install s6-overlay ****" && \ 
  curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' > /etc/S6_RELEASE && \
  wget https://github.com/just-containers/s6-overlay/releases/download/`cat /etc/S6_RELEASE`/s6-overlay-armhf.tar.gz -O /tmp/s6-overlay-armhf.tar.gz >/dev/null 2>&1 && \
  tar xzf /tmp/s6-overlay-armhf.tar.gz -C / >/dev/null 2>&1 && \
  rm -f /tmp/s6-overlay-armhf.tar.gz >/dev/null 2>&1 && \
  echo "**** Installed s6-overlay `cat /etc/S6_RELEASE` ****"

VOLUME [ "/config" ]

RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh

RUN chown 911:911 /config && \
    addgroup -g 911 abc && \
    adduser -u 911 -D -G abc abc

EXPOSE 8080
# Setup EntryPoint
ENTRYPOINT [ "/init" ]
