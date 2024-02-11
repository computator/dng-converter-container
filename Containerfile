FROM docker.io/library/debian:12-slim AS wine

RUN set -eux; \
	export DEBIAN_FRONTEND=noninteractive; \
	dpkg --add-architecture i386; \
	apt-get update; \
	apt-get -y install --no-install-recommends wine wine64 wine32; \
	rm -rf /var/lib/apt/lists/*

ENV WINEPREFIX=/opt/dngconverter WINEDEBUG=-all

FROM wine AS setup

ENV SETUP_FNAME=AdobeDNGConverter_x64_16_1.exe
RUN set -eux; \
	apt-get update; \
	apt-get -y install --no-install-recommends xvfb xauth curl ca-certificates; \
	[ -e /cache/$SETUP_FNAME ] && ln -s /cache/$SETUP_FNAME $SETUP_FNAME || curl -O https://download.adobe.com/pub/adobe/dng/win/$SETUP_FNAME; \
	xvfb-run sh -euxc ' \
		winecfg /v win10; \
		wine $SETUP_FNAME /VERYSILENT; \
		wine /opt/dngconverter/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe -c || true; \
		'; \
	rm $SETUP_FNAME

FROM wine

COPY --from=setup $WINEPREFIX $WINEPREFIX
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /images
LABEL org.opencontainers.image.source=https://github.com/computator/dng-converter-ctr
