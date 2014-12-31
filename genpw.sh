#!/bin/bash

#! This script does not gaurantee that a character from each category is
#	present in the generated password

LENGTH=30		#! Should be the actual length minus one
NUMBER=0-9		#! Numbers allowed
UPPERCASE=A-Z	#! Upprecase letters allowed
LOWERCASE=a-z	#! Lowercase letters allowed
SPECIAL=_#!		#! Special characters allowed

< /dev/urandom tr -dc ${UPPERCASE}${LOWERCASE}${NUMBER}${SPECIAL} \
	| head --bytes=${LENGTH};echo;

