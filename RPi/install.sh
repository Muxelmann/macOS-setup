#!/urs/bin/env bash

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
    echo -e "${UNDERLINE}${YELLOW}Error${RESET}: $*" # highlight Error with underline and red color
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

# Define the installers

install_minecraft() {
  omain "Minecraft setup";
  
  minecraft_user="minecraft"
  minecraft_group=${minecraft_user}
  minecraft_home="/home/${minecraft_user}"
  
  oprint "Creating minecraft user"
  if id "${minecraft_user}" &>/dev/null; then
    oerror "User named ${minecraft_user} already exists"
  else
    sudo adduser --system --home ${minecraft_home} ${minecraft_user}
    sudo addgroup --system ${minecraft_group}
    sudo adduser ${minecraft_user} ${minecraft_group}
    sudo chown -R ${minecraft_user}:${minecraft_group} ${minecraft_home}
  fi

  oprint "Downloading Minecraft Server Java edition"
  minecraft_page=$(curl -s https://www.minecraft.net/en-us/download/server)
  minecraft_url=$(echo "${minecraft_page}" | grep -o '<a .*href=.*\.jar".*>' | sed -e 's/<a/\n<a/g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d')
  minecraft_file=$(echo "${minecraft_page}" | grep -o '<a .*href=.*\.jar".*>.*</a>' | sed -e 's/<\/a>//g' -e 's/.*>//g')

  if [ -f "${minecraft_file}" ]; then
    owarning "${minecraft_file} already exists!"
    read -p "Would you like to redownload [y/N]? " -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      rm ${minecraft_file}
      curl ${minecraft_url} --output ${minecraft_home}/${minecraft_file}
    fi
  else
    curl ${minecraft_url} --output ${minecraft_home}/${minecraft_file}
  fi
  sudo chmod 775 ${minecraft_home}/${minecraft_file}
  sudo chowm ${minecraft_user}:${minecraft_group} ${minecraft_home}/${minecraft_file}
  ln -s ${minecraft_home}/${minecraft_file} ${minecraft_home}/server.jar

  oprint "Creating the Minecraft service"
  minecraft_service=minecraft-server.service
  minecraft_service_path=/lib/systemd/system/${minecraft_service}
  if [ -f "${minecraft_service_path}" ]; then
    owarning "Minecraft service already exists!"
    read -p "Would you like to recreate it [y/N]? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo systemctl stop ${minecraft_service}
      sudo systemctl disable ${minecraft_service}
      sudo rm ${minecraft_service_path}
    else
      sudo systemctl restart ${minecraft_service}
    fi
  fi

  # Only crete a service if it does not yet exist
  if [ ! -f "${minecraft_service}" ]; then
    cat >> ${minecraft_service_path} <<EOT
[Unit]
Description=start and stop the minecraft-server 

[Service]
WorkingDirectory=${minecraft_home}
User=minecraft
Group=minecraft
Restart=on-failure
RestartSec=20 5
ExecStart=/usr/bin/java -Xms1536M -Xmx1536M -jar server.jar nogui

[Install]
WantedBy=multi-user.target
EOT
  fi

  sudo systemctl enable ${minecraft_service}
  sudo systemctl start ${minecraft_service}

  osuccess "Minecraft installed"
}

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
      install_minecraft
      ;;
    *)
      break
      ;;
  esac
done
