#!/bin/bash
#
#! Author: Bezeredi, Evan D.
#
#! Generate a random MAC address
#
#  OPTIONS
#     -h | --help
#        Displays usage information
#
#     --no-number
#        Removes the character set for numbers
#
#     --no-letter
#        Removes the character set for letters
#
#     --upper
#        Outputs characters in uppercase instead of lowercase
#
#     --lower
#        Outputs characters in lowercase [default]
#
#     --no-newline
#        Do no add a newline character at the end of the password
#
#     --
#        Designates the end of options to be parsed


NUM_RANGE="0-9"          #! Numbers allowed
CHAR_RANGE="a-f"
PROGNAME=`basename "$0"`


#! Parse options
while [[ "$1" != "" ]]; do
	case "$1" in
		"--help" | "-h")
			echo "Usage: $PROGNAME [--no-number] [--upper] [--lower]" \
			     "[--no-newline] [--]"
			exit;;
		"--no-number")  NUM_RANGE="";     shift;;
		"--no-letter")  CHAR_RANGE="";    shift;;
		"--upper")      CHAR_RANGE="A-F"; shift;;
		"--lower")      CHAR_RANGE="a-f"; shift;;
		"--no-newline") NO_NEWLINE=true;  shift;;
		"--")                     shift;  break;;
		*)
			echo "$PROGNAME: unrecognized option: $1. Exit."
			exit;;
	esac
done


#! Generate the MAC address, one field at a time
for((count=0; count <= 5; count++)); do
	macaddr+=`< /dev/urandom tr -dc ${CHAR_RANGE}${NUM_RANGE} | head --bytes=2`
	
	if [[ count -ne 5 ]]; then
		macaddr+=":"
	fi
done

#! TODO: ECHO_ARGS
if [[ -v NO_NEWLINE ]]; then
	echo -n "$macaddr"
else
	echo "$macaddr"
fi

