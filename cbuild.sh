#!/bin/sh
set -e

: ${VERSION:=11.1}

ctr=$(buildah from wine:3.0)

WINEPREFIX=/opt/dngconverter
buildah config \
	--env WINEPREFIX="$WINEPREFIX" \
	--env WINEDEBUG=-all \
	$ctr

buildah add $ctr "http://download.adobe.com/pub/adobe/dng/win/DNGConverter_$(echo "$VERSION" | tr . _).exe" /tmp/
buildah run $ctr wine "/tmp/DNGConverter_$(echo "$VERSION" | tr . _).exe" /S
buildah run $ctr rm -f "/tmp/DNGConverter_$(echo "$VERSION" | tr . _).exe"

buildah config \
	--entrypoint '["/usr/bin/wine", "/opt/dngconverter/drive_c/Program Files/Adobe/Adobe DNG Converter/Adobe DNG Converter.exe"]' \
	--cmd "-c" \
	--volume /images \
	--workingdir /images \
	$ctr

img=$(buildah commit --rm $ctr dng-converter)
buildah tag $img dng-converter:"$VERSION"