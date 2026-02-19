#!/usr/bin/env bash
#
# Set the metadata for movies and shows before adding them to Plex.
#   * TV shows are assumed to be organized and name appropriately.
#   * Movies are assumed to be named appropriately.
#     They are then moved into a folder that is appropriately named.


# Set the metadata for a properly named movie MKV
# and move it into an appropriately named folder
function organize_movie() {
  local filename="$1"
  local bname=$(basename "$filename")

  local btitle=$(echo "$bname" | sed -e 's/ ([0-9]\{4\}.*//g')
  local title=$(echo "$btitle" | sed -e 's/ - /: /g')
  local edition=$(echo "$bname" | grep -o "{edition-[^}]*}" | tr -d "{}" | sed -e 's/edition-//g' || echo "")
  local year=$(echo "$bname" | grep -Eo '\([0-9]{4}\)' | tr -d '()' )
#  local ext="${bname##*.}"
#  local resolution=$(echo "$bname" | grep -Eo " - [0-9]{1,4}[p|k|i].$ext" | sed -e "s/ - //g" -e 's/.mkv//g')

  # Set the title property on the file
  echo "  $title"
  mkvpropedit --set title="$title" "$filename" > /dev/null 2>&1

  # Make the directory for the file
  if [ -z "$edition" ]; then
    local dname="./movies/$btitle ($year)"
  else
    local dname="./movies/$btitle ($year) {edition-$edition}"
  fi

  mkdir -p "$dname"
  mv "$filename" "$dname"
}

export -f organize_movie


# Set the metadata for the supplied episode
function organize_episode() {
    local filename="$1"
    local bname=$(basename "$filename")
    local episode=$(echo "$bname" | grep -Eo "s[0-9]+e[0-9]+")
    local ext="${bname##*.}"
    local resolution=$(echo "$bname" | grep -Eo " - [0-9]{1,4}[p|k|i].$ext" | sed -e "s/ - //g" -e 's/.mkv//g')
    local title=$(echo "$bname" | sed -e "s/^.*$episode - //g" -e "s/ - $resolution.$ext$//g" -e "s/ - /: /g")

    # Set the title property on the file
    echo "      $episode: $title"
    mkvpropedit --set title="$title" "$filename" > /dev/null 2>&1
}

export -f organize_episode


# Set the metadata for each episode in a season
function organize_season() {
  local seasonroot="${1%/.ready}"
  local seasonName=$(basename "$seasonroot")

  echo "    $seasonName"
  find "$seasonroot" \
    -mindepth 1 \
    -maxdepth 1 \
    -type f \
    -iname "*.mkv" \
    -exec bash -c 'organize_episode "$1"' _ {} \;

  # remove season .ready file
  rm "$1"
}

export -f organize_season


# Set the metadata for seasons ready to process
function organize_show() {
  local showroot="${1%/.ready}"
  local showName=$(basename "$showroot" | sed -e "s/ - /: /g")

  echo "  $showName"
  find "$showroot" \
    -mindepth 2 \
    -maxdepth 2 \
    -type f \
    -name ".ready" \
    -exec bash -c 'organize_season "$1"' _ {} \;

  # remove the show .ready file
  rm "$1"
}

export -f organize_show


# Main function
function main() {
  local movies=false
  local shows=false

  for arg in "$@"; do
    case $arg in
      -m | --movies) movies=true ;;
      -s | --shows)  shows=true  ;;
      *) ;;
    esac
  done

  if [ "$movies" = true ]; then
    echo "Organizing Movies..."
    find ./movies \
      -mindepth 1 \
      -maxdepth 1 \
      -iname "*.mkv" \
      -exec bash -c 'organize_movie "$1"' _ {} \;
  fi

  if [ "$shows" = true ]; then
    echo "Processing Shows..."
    find ./tv-shows \
      -mindepth 2 \
      -maxdepth 2 \
      -type f \
      -iname ".ready" \
      -exec bash -c 'organize_show "$1"' _ {} \;
  fi
}

# script entrance point
main "$@"
