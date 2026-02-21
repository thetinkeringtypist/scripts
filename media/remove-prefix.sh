#!/usr/bin/env bash
#
# Splits and removes prefixes for a given mkv file.
# Assumes the existence of a ramdisk at /mnt/ramdisk.

function split_mkv() {
  local name="${1#./}"
  local episode="${name#*e}"
  local temp_dir="/mnt/ramdisk"

  echo "Splitting $name"
  mkvmerge --split timestamps:$ts --output "$temp_dir/$episode" "$name" > /dev/null 2>&1

  rm "$temp_dir/${episode%.mkv}-001.mkv"
  mv "$temp_dir/${episode%.mkv}-002.mkv" "$name"

  mkdir -p "done"
  mv "$name" "done/$name"
}

export -f split_mkv


function main() {
  if [[ -z "$1" ]]; then
    echo "Time needed"
    exit
  fi

  export ts="$1"

  find . \
    -mindepth 1 \
    -maxdepth 1 \
    -iname "*.mkv" \
    -exec bash -c 'split_mkv $1' \
    _ {} \;
}

main "$@"
