FROM lsiobase/alpine:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	g++ \
	jq \
	make \
	python2-dev \
	tar && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	mediainfo \
	nodejs-npm \
	rtorrent \
	screen && \
 echo "**** install flood ****" && \
 mkdir -p \
	/app/flood && \
 FLOOD_RAW_COMMIT=$(curl -sX GET "https://api.github.com/repos/jfurrow/flood/commits/master" \
		| jq -r .sha) && \
 FLOOD_COMMIT="${FLOOD_RAW_COMMIT:0:7}" && \
 curl -o \
 /tmp/flood.tar.gz -L \
	"https://github.com/jfurrow/flood/archive/${FLOOD_COMMIT}.tar.gz" && \
 tar xf \
 /tmp/flood.tar.gz -C \
	/app/flood --strip-components=1 && \
 cp /app/flood/config.docker.js /app/flood/config.js && \
 cd /app/flood && \
 npm install && \
 npm run build && \
 npm prune --production && \
 echo "**** configure flood ****" && \
 sed -i \
	-e "s#dbPath: '.*',#dbPath: '/config/flood/db/',#" \
	-e "s#sslKey: '.*',#sslKey: '/config/flood/flood_ssl.key',#" \
	-e "s#sslCert: '.*'#sslCert: '/config/flood/flood_ssl.cert'#" \
	-e "s#socketPath: '.*'#socketPath: '/config/rtorrent/rtorrent.sock'#" \
 /app/flood/config.js && \
 echo "**** clean up ****" && \
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
