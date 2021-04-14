#!/usr/bin/env bash

# Define some colors
RED="\\033[31m"       # normal red
GREEN="\\033[32m"     # normal green
YELLOW="\\033[33m"    # normal yellow
BLUE="\\033[34m"      # normal blue
MAGENTA="\\033[35m"   # normal magenta
CYAN="\\033[36m"      # normal cyan
WHITE="\\033[37m"     # normal white

RESET="\\033[0m"      # normal reset
BOLD="\\033[1m"       # bold
UNDERLINE="\\033[4m"  # underline

# Define the correct dotfile
case "$SHELL" in
bash )
  shell_profile="$HOME/.bashrc"
  ;;
zsh )
  shell_profile="$HOME/.zshrc"
  ;;
ksh )
  shell_profile="$HOME/.profile"
  ;;
fish )
  shell_profile="$HOME/.config/fish/config.fish"
  ;;
* )
  shell_profile="your profile"
  ;;
esac

# Define helper functions
omain() {
  if [[ -t 1 ]] # check whether stdout is a tty.
  then
    echo -e "${GREEN}==>${RESET} ${BOLD}$*${RESET}"
  else
    echo "==> $*"
  fi
}

oprint() {
  if [[ -t 1 ]]; then
    echo -e "${BLUE}-->${RESET} $*"
  else
    echo "==> $*"
  fi
}

owarning() {
  if [[ -t 1 ]] # check whether stdout is a tty.
  then
    echo -e "${UNDERLINE}${YELLOW}Warning${RESET}: $*" # highlight Error with underline and red color
  else
    echo "==> $*"
  fi
}

osuccess() {
  echo " ✅  $*"
}

oerror() {
  if [[ -t 1 ]]; then
    echo -e "${UNDERLINE}${RED}Error${RESET}: $*" # highlight Error with underline and red color
  else
    echo "Error: $*"
  fi
  exit
}

# Waits until the file exists e.g.:
# wait_file "server-log.txt" 5 || {
#   echo "JBoss log file missing after waiting for 5 seconds: 'server-log.txt'"
#   exit 1
# }
wait_file() {
  local file="$1"
  shift
  # 10 seconds as default timeout
  local wait_seconds="${1:-10}"
  shift

  until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do
    sleep 1;
  done

  ((++wait_seconds))
}
