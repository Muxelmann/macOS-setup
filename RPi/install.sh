#!/usr/bin/env bash

# Parse flags and arguments
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "install.sh - installs apps/tools on RPi"
      echo " "
      echo "install.sh [-f, --flag, --arg=value]"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-m, --minecraft           installs the latest minecraft server with dameon"
      exit 0
      ;;
    -m|--minecraft*)
      shift # Removes the arg so that the next one can be read in
      . ./service-minecraft.sh
      ;;
    *)
      break
      ;;
  esac
done