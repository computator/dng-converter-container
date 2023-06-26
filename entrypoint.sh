#!/bin/sh
set -e

if [ "${1}" != "${1#-*}" ] || ! command -v "${1}" > /dev/null; then
	# This awk script translates any arguments after '--' to windows paths using winepath
	awk '
		BEGIN {
			# set output separators to null byte
			OFS = ORS = "\x00"
			# search for marker while printing arguments
			for(i = 1; i < ARGC; i++) {
				if (ARGV[i] == "--") {
					# skip past marker
					i++
					break
				}
				print ARGV[i]
			}
			# translate any remaining arguments after marker via xargs
			for(; i < ARGC; i++)
				print ARGV[i] | "xargs -0 winepath -w0 --"
			exit
		}
		' "$@" | xargs -0 wine "/opt/dngconverter/drive_c/Program Files/Adobe/Adobe DNG Converter/Adobe DNG Converter.exe"
		exit $?
fi

exec "$@"
