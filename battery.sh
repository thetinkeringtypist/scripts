#!/bin/bash
#
#! Author: Bezeredi, Evan D.
#
#! This script makes battery information easily available at the command line.
#
#  NOTE: This script currently expects a kernel version of at least 3.19
  

PROGNAME=$(basename "$0")
percent=$(cat "/sys/class/power_supply/BAT0/capacity")
percent="$percent%" 
status=$(cat "/sys/class/power_supply/BAT0/status")

#! Parse options
while [[ "$1" != "" ]]; do
	case "$1" in
		"--help" | "-h")
			echo "Usage: $PROGNAME [-h]"
			exit;;
		*)
			echo "$PROGNAME: unrecognized option: $1. Exit."
			exit;;
	esac
done

#! Perform the actions
echo "$percent ($status)"

