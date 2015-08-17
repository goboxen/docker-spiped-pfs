# vim:set ft=dockerfile:
FROM debian:7

MAINTAINER Junaid Loonat <junaid@loonat.net>

RUN buildDeps1='ca-certificates wget' \
	&& set -x \
	&& apt-get update \
	&& apt-get install -y $buildDeps1 --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove $buildDeps1

ENV SPIPED_VERSION 1.5.0
ENV SPIPED_PKGURL https://www.tarsnap.com/spiped/spiped-${SPIPED_VERSION}.tgz
ENV SPIPED_SHA256 b2f74b34fb62fd37d6e2bfc969a209c039b88847e853a49e91768dec625facd7
ENV SPIPED_KEYDIR /spiped

RUN buildDeps2='ca-certificates curl gcc make libssl-dev' \
	&& set -x \
	&& apt-get update \
	&& apt-get install -y $buildDeps2 libssl1.0.0 --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/spiped \
	&& curl -sSL "$SPIPED_PKGURL" -o spiped.tgz \
	&& echo "$SPIPED_SHA256 *spiped.tgz" | sha256sum -c - \
	&& tar -xzf spiped.tgz -C /usr/src/spiped --strip-components=1 \
	&& rm spiped.tgz \
	&& make -C /usr/src/spiped install \
	&& rm -r /usr/src/spiped \
	&& apt-get purge -y --auto-remove $buildDeps2 \
	&& mkdir ${SPIPED_KEYDIR} \
	&& useradd -m spiped-user

VOLUME $SPIPED_KEYDIR

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8022

