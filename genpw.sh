#!/bin/bash

#! This script does not gaurantee that a character from each category is
#	present in the generated password

LENGTH=30		#! Should be the actual length minus one
NUMBER=0-9		#! Numbers allowed
UPPERCASE=A-Z	#! Upprecase letters allowed
LOWERCASE=a-z	#! Lowercase letters allowed
SPECIAL=_#!		#! Special characters allowed


#! Help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	PROGNAME=`basename "$0"`
	echo "usage: $PROGNAME [length]"
	exit

#! Check the length of the password
elif [ "$1" -eq "$1" ] 2>/dev/null; then
	LENGTH="$1"
fi


< /dev/urandom tr -dc ${UPPERCASE}${LOWERCASE}${NUMBER}${SPECIAL} \
	| head --bytes=${LENGTH};echo;

