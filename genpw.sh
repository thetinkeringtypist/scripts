#!/bin/bash

#! This script does not gaurantee that a character from each category is
#	present in the generated password

LENGTH=64        #! Should be the actual length minus one
NUMBER="0-9"     #! Numbers allowed
UPPERCASE="A-Z"  #! Upprecase letters allowed
LOWERCASE="a-z"  #! Lowercase letters allowed
SPECIAL="_#!&^$" #! Special characters allowed
PROGNAME=`basename "$0"`


#! Parse options
while [[ "$1" != "" ]]; do
	case "$1" in
		"--help" | "-h")
			echo "Usage: $PROGNAME [--no-special] [--no-number] [--no-upper]" \
			     "[--no-lower] [--] [n]"
			exit;;
		"--no-special") SPECIAL="";   shift;;
		"--no-number")  NUMBER="";    shift;;
		"--no-upper")   UPPERCASE=""; shift;;
		"--no-lower")   LOWERCASE=""; shift;;
		"--")                         shift; break;;
		*)
			#! Check the length
			if [ "$1" -eq "$1" ] 2>/dev/null; then
				LENGTH="$1"
				shift
				continue
			fi

			echo "$PROGNAME: unrecognized option: $1. Exit."
			exit;;
	esac
done


#! Check character sets
if [[ "$SPECIAL" == ""   &&
		"$NUMBER" == ""    &&
		"$UPPERCASE" == "" &&
		"$LOWERCASE" == "" ]]; then
	echo "$PROGNAME: requires at least one non-empty character set. Exit."
	exit
fi


#! Generate the password
< /dev/urandom tr -dc ${UPPERCASE}${LOWERCASE}${NUMBER}${SPECIAL} \
	| head --bytes=${LENGTH};echo;

