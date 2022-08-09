#!/bin/bash

USAGE="
Usage: $ ./whisper_verion.sh [options]
  options:
    -t, --tag-prefix, Tag prefix (default \"whisper-beaglebone\")
    -b, --build, Build type (default \"DEV\")
    -d, --debug, Enable debug logging
    -f=, --format=, Specify output format (default \"whisper\")
    -h, --help, Print this message and exit
"

TAG_PREFIX="whisper-beaglebone"
BUILD="DEV"
WHISPER_VERSION_DEBUG_LOG=false
FORMAT="whisper"

while [ -n "$1" ]; do
  case "$1" in
    -t | --tag-prefix )  shift
                         TAG_PREFIX="$1"
                         ;;
    -b | --build )       shift
                         BUILD="$1"
                         ;;
    -f=* | --format=* )  FORMAT="${1#*=}"
                         ;;
    -d | --debug )       WHISPER_VERSION_DEBUG_LOG=true
                         ;;
    -h | --help )        echo "$USAGE"
                         exit 0
                         ;;
    * )                  >&2 echo "Unknown argument \"$1\""
                         echo "$USAGE"
                         exit 1
                         ;;
  esac
  shift
done

source $(dirname "$0")/whisper_version_lib.sh

if ! is_valid_build "$BUILD"; then
  exit 1
fi

if ! is_valid_tag_prefix "$TAG_PREFIX"; then
  exit 1
fi

case "$FORMAT" in
  whisper )    get_release_name "$TAG_PREFIX" "$BUILD"
               ;;
  bootloader ) get_release_name_bl "$TAG_PREFIX" "$BUILD"
               ;;
  export )     get_export_args "$TAG_PREFIX" "$BUILD"
               ;;
  * )          >&2 echo "Unknown format \"$FORMAT\""
               exit 1
               ;;
esac
