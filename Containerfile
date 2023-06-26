FROM docker.io/library/debian:12-slim

RUN set -eux; \
	export DEBIAN_FRONTEND=noninteractive; \
	dpkg --add-architecture i386; \
	apt-get update; \
	apt-get -y install --no-install-recommends wine wine64 wine32; \
	rm -rf /var/lib/apt/lists/*

ENV WINEPREFIX=/opt/dngconverter WINEDEBUG=-all
ENV SETUP_FNAME=AdobeDNGConverter_x64_15_4.exe

RUN set -eux; \
	DEPS='xvfb xauth curl ca-certificates'; \
	apt-get update; \
	apt-get -y install --no-install-recommends $DEPS; \
	[ -e /cache/$SETUP_FNAME ] && ln -s /cache/$SETUP_FNAME $SETUP_FNAME || curl -O https://download.adobe.com/pub/adobe/dng/win/$SETUP_FNAME; \
	xvfb-run sh -euxc ' \
		winecfg /v win10; \
		wine AdobeDNGConverter_x64_15_4.exe /VERYSILENT; \
		wine /opt/dngconverter/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe -c || true; \
		'; \
	rm $SETUP_FNAME; \
	apt-get -y purge --autoremove $DEPS; \
	rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /images
LABEL org.opencontainers.image.source=https://github.com/computator/dng-converter-ctr
