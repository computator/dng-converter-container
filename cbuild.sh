#!/bin/sh
set -e

: ${VERSION:=10_5}

ctr=$(buildah from ubuntu:18.04)

buildah run --network host $ctr sh -c '
	export DEBIAN_FRONTEND=noninteractive
	dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -y install wine-stable'
buildah run $ctr sh -c "[ -d /var/lib/apt/lists ] && rm -rf /var/lib/apt/lists/*"

buildah config --env WINEPREFIX=/opt/dngconverter $ctr

buildah add $ctr "http://download.adobe.com/pub/adobe/dng/win/DNGConverter_${VERSION}.exe" /tmp/
buildah run $ctr wine /tmp/DNGConverter_${VERSION}.exe /S
buildah run $ctr rm -f /tmp/DNGConverter_${VERSION}.exe

buildah config \
	--entrypoint '["/usr/bin/wine", "/opt/dngconverter/drive_c/Program Files/Adobe/Adobe DNG Converter/Adobe DNG Converter.exe"]' \
	--cmd "-c" \
	--volume /images \
	--workingdir /images \
	--env WINEDEBUG=-all \
	$ctr

img=$(buildah commit --rm $ctr dng-converter)
buildah tag $img dng-converter:"$(printf '%s' "$VERSION" | tr _ .)"