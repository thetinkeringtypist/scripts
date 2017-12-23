#!/bin/bash
#
#! Script to empty user trash cans and zero out unused
#  blocks on system partitions
#
#! This script is an excellent preliminary step to shrinking virtual
#  hard disk files or capturing hard drive images for cloning
#
#! Author: Bezeredi, Evan D.
PROGNAME=$(basename $0)
CLEANUP=false
TURNOFF=false

#! Verify user permissions
if [ "$USER" != "root" ]; then
	echo "$PROGNAME: must be run as root. Exiting."
	exit
fi


#! Prompt about cleaning up trash cans
while true; do
	echo -n "Clean out root and user trash cans? [y]/n: "
	read cleanup
	
	case "$cleanup" in
		Y|y|"") CLEANUP=true;      break;;
		N|n)    CLEANUP=false;     break;;
		  *)    CLEANUP="invalid"; break;;
	esac
	
	if [ "$CLEANUP" != "invalid" ]; then
		break
	fi
done


#! Prompt about shutting down the system after script completion
while true; do
	echo -n "Shutdown the system after script is complete? [y]/n: "
	read turnoff
	
	case "$turnoff" in
		Y|y|"") TURNOFF=true;      break;;
		N|n)    TURNOFF=false;     break;;
		  *)    TURNOFF="invalid"; break;;
	esac

	if [ "$TURNOFF" != "invalid" ]; then
		break
	fi
done


#! Removes contents of user trash cans
if [ $CLEANUP = true ]; then
	homedirs=$(ls /home)
	for homedir in /root $homedirs; do
		trashdir=$homedir/.local/share/Trash
		if [ -e $trashdir ]; then
			echo -n "Removing trash in $trashdir... "
			rm -rf $trashdir/*
			echo "done."
		else
			echo "$trashdir does not exist. Skipping."
		fi
	done
fi


#! Zeroes out unused blocks on partitions
#  NOTE: ignores boot and system partitions
mounts=$(grep "^/" /proc/mounts | awk '{print $2}' | grep -v "^/boot" | tr '\n' ' ')
for dir in $mounts; do
	echo -n "Zeroing out free blocks on $dir... "
	cd $dir
	cat /dev/zero > zero.dat 2>&1
	sync
	sleep 1
	sync
	rm -f zero.dat
	echo "done."
done

#! Power off the machine, if requested
if [ $TURNOFF = true ]; then
	shutdown -P now
fi

