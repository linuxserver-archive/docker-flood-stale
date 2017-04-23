FROM lsiobase/alpine:3.5
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	tar && \

# install runtime packages
 apk add --no-cache \
	nodejs \
	rtorrent \
	screen && \

# install flood
 mkdir -p \
	/app/flood && \
 curl -o \
 /tmp/flood.tar.gz -L \
	https://github.com/jfurrow/flood/archive/master.tar.gz && \
 tar xf \
 /tmp/flood.tar.gz -C \
	/app/flood --strip-components=1 && \
 cd /app/flood && \
 npm install --production && \

# configure flood
 cp /app/flood/config.template.js /app/flood/config.js && \
 sed -i \
	-e "s#dbPath: '.*',#dbPath: '/config/flood/db/',#" \
	-e "s#sslKey: '.*',#sslKey: '/config/flood/flood_ssl.key',#" \
	-e "s#sslCert: '.*'#sslCert: '/config/flood/flood_ssl.cert'#" \
	-e "s#socketPath: '.*'#socketPath: '/config/rtorrent/rtorrent.sock'#" \
	/app/flood/config.docker.js && \

# clean up
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root \
	/tmp/* && \
 mkdir -p \
	/root

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
VOLUME /config /downloads
