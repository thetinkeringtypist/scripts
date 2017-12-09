#!/bin/bash
#
#! Author: Bezeredi, Evan D.
#
#! This script removes stale kernel images, extras, and headers that may be
#  installed on the system.
#
#  NOTE: This is for apt-get based systems like Ubuntu and Linux Mint.
#

PROGNAME=$(basename "$0")
kernel_version=$(uname -r | egrep -o ".*[0-9]")
candidate_packages=$(dpkg-query --show --showformat='${Package}\n' \
	linux-image-* linux-headers-* \
	| grep --invert-match "$kernel_version")

#! Filter out virtual packages
packages=""
for package in $candidate_packages; do
	size=$(dpkg-query --show --showformat='${Installed-size}' "$package")

	#! If the package has no installed size (ie. a virtual package), skip
	if [ "$size" == "" ]; then
		continue
	fi

	packages="$packages $package"
done

#! Remove stale kernel images, extras, and headers
if [ "$packages" == "" ]; then
	echo "$PROGNAME: no stale kernel images, extras, or headers found. Exit."
	exit
else
	sudo apt-get purge $(echo "$packages")
	sudo find /lib/modules -mindepth 1 -maxdepth 1 \
		-not -name "$kernel_version*" -exec rm -rf {} \;
fi
