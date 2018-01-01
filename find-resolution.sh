#!/bin/bash
#
#! Author: Bezeredi, Evan D.
#
#! This script finds videos with a given resolution.
#
#  OPTIONS
#     -h | --help
#        Displays usage information
#
#     -r <n> | --resolution <n>
#        Set the resolution to look for (default is 720)
#
#     -d <dir-name> | --directory <dir-name>
#        Set the directory to look under, recursively (default is .)
#     --
#        Designates the end of options to be parsed

PROGNAME=`basename "$0"`
RESOLUTION="720"
SEARCH_DIR="."


#! Check that libav-tools is installed
if [ -z $(which ffprobe) ]; then
	echo "$PROGNAME: requires ffmpeg to be installed. Exit."
	exit
fi


#! Parse options
while [[ "$1" != "" ]]; do
	case "$1" in
		"--help" | "-h")
			echo "Usage: $PROGNAME [-r <n> | --resolution <n>]" \
				"[-d <dir-name> | --directory <dir-name>] [--]"
			exit;;

		"-r" | "--resolution") shift;
			#! Verify resolution is a number and greater than zero
			if [ "$1" -eq "$1" ] 2>/dev/null; then
				if [ "$1" -le 0 ]; then
					echo "$PROGNAME: resolution must be greater than 0. Exit."
					exit
				fi

				RESOLUTION="$1"
				shift
				continue
			fi

			echo "$PROGNAME: resolution must be a number (not ending in p). Exit."
			exit;;

		"-d" | "--directory")  shift;
			if [ ! -d "$1" ]; then
				echo "$PROGNAME: directory $1 does not exist or is not a" \
						"directory. Exit."
				exit
			fi

			SEARCH_DIR="$1"
			shift
			continue;;

		"--")                                    shift;  break;;
		*)
			echo "$PROGNAME: unrecognized option: $1. Exit."
			exit;;
	esac
done


#! Search for videos
find "$SEARCH_DIR" -type f \
\( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.avi" \) \
-exec sh -c \
"ffprobe -show_streams 2>/dev/null \"{}\" | grep -q 'coded_height=$RESOLUTION'" \
\; -print
