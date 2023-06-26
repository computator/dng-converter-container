#!/bin/sh
set -e

if [ "${1}" != "${1#-*}" ] || ! command -v "${1}" > /dev/null; then
	exec wine "/opt/dngconverter/drive_c/Program Files/Adobe/Adobe DNG Converter/Adobe DNG Converter.exe" "$@"
fi

exec "$@"
