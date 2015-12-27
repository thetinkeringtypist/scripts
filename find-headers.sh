#!/bin/bash
#
#! Author: Bezeredi, Evan D.
#
#! Get a list of unique headers used in a C or C++ project. The directories
#  searched (recursively) are ./src and ./include
#
#  NOTE: When using --spaces, commas, --tabs, or --newlines only the last
#        argument is used.
#
#  --spaces
#     Delimit headers with spaces instead of newlines
#
#  --commas
#     Delimit headers with commas instead of newlines
#
#  --tabs
#     Delimit headers with tabs instead of newlines
#
#  --newlines
#     Delimit headers with (default)
#
#  --
#     End of parsable arguments


PROGNAME=`basename "$0"`
DELIMITER='\n'
SEARCH_DIRS=""


#! Parse options
while [ "$1" != "" ]; do
	case "$1" in
		"--help" | "-h")
			echo "Usage: $PROGNAME [--spaces] [--commas] [--tabs] [--newlines]"
			exit;;
		"--spaces")   DELIMITER=' ';  shift;;
		"--commas")   DELIMITER=','; shift;;
		"--tabs")     DELIMITER='\t'; shift;;
		"--newlines") DELIMITER='\n'; shift;;
		"--")         shift; break;;
		*)
			#! If a directory was specified, add it to the list to search
			if [ -d "$1" ]; then
				SEARCH_DIRS+=" $1"
				shift
				continue
			fi

			#! Error reporting
			echo "$PROGNAME: unrecognized option or not a directory: $1. Exit."
			exit;;
	esac
done


#! If no search directories were specified, then set the default directories
if [ "$SEARCH_DIRS" == "" ]; then
	SEARCH_DIRS="./src ./include"
fi


#! Perform operations
PAYLOAD=`grep --no-filename --color=no -r "^#include <.*>" $SEARCH_DIRS`
echo "$PAYLOAD" | sed -e "s/#include <//g" -e "s/>//g" \
		| tr '\n' "$DELIMITER" | sort | uniq

