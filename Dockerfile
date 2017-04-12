FROM lsiobase/alpine:3.5
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# install packages
RUN \
 apk add --no-cache \
	git \
	nodejs \
	rtorrent \
	screen && \

# install flood
 git clone https://github.com/jfurrow/flood.git /app/flood && \
 cd /app/flood && \
 npm install --production && \

# configure flood
 cp /app/flood/config.template.js /app/flood/config.js && \
 sed -i \
	"s#dbPath: './server/db/',#dbPath: '/config/flood/',#" \
	/app/flood/config.js && \

# clean up
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
