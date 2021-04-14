#!/usr/bin/env bash

. ./utils.sh

minecraft_user="minecraft"
minecraft_group=${minecraft_user}
minecraft_home="/home/${minecraft_user}"

minecraft_service=minecraft-server.service
minecraft_service_path=/lib/systemd/system/${minecraft_service}  
minecraft_port=25565
minecraft_rcon_port=25575
minecraft_rcon_password=$(openssl rand -hex 12)

if [ "${1}" != "--source-only" ]; then
  omain "Installing Minecraft Service"

  sudo apt update
  sudo apt -y install git openjdk-11-jre


  oprint "Creating minecraft user"
  if id "${minecraft_user}" &>/dev/null; then
    oerror "User named ${minecraft_user} already exists"
  else
    sudo adduser --system --home ${minecraft_home} ${minecraft_user}
    wait_file ${minecraft_home} 10 || {
      oerror "${minecraft_home} was not created in time"
    }
    sudo addgroup --system ${minecraft_group}
    sudo adduser ${minecraft_user} ${minecraft_group}
    sudo chown -R ${minecraft_user}:${minecraft_group} ${minecraft_home}
    sudo chmod -R 775 ${minecraft_home}
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
      sudo rm ${minecraft_file}
      sudo rm ${minecraft_home}/server.jar
      sudo curl ${minecraft_url} --output ${minecraft_home}/${minecraft_file}
    fi
  else
    sudo curl ${minecraft_url} --output ${minecraft_home}/${minecraft_file}
  fi
  sudo chmod 775 ${minecraft_home}/${minecraft_file}
  sudo chowm ${minecraft_user}:${minecraft_group} ${minecraft_home}/${minecraft_file}
  ln -s ${minecraft_home}/${minecraft_file} ${minecraft_home}/server.jar

  oprint "Creating the Minecraft Service"

  sudo git clone https://github.com/Tiiffi/mcrcon.git ${minecraft_home}/mcrcon
  cd ${minecraft_home}/mcrcon && sudo make
  sudo chmod 775 ${minecraft_home}/mcrcon/mcrcon

  # Creating files: start, stop, eula.txt etc.
  if [ -f ${minecraft_home}/start ]; then
    sudo rm ${minecraft_home}/start
  fi
  sudo bash -c "cat <<EOF > ${minecraft_home}/start
#! /bin/sh
/usr/bin/java -Xms2048M -Xmx2048M -jar server.jar nogui
EOF"
  sudo chmod 775 ${minecraft_home}/start
  sudo chown ${minecraft_user}:${minecraft_group} ${minecraft_home}/start

  if [ -f ${minecraft_home}/stop ]; then
    sudo rm ${minecraft_home}/stop
  fi
  sudo bash -c "cat <<EOF > ${minecraft_home}/stop
#!/bin/sh
${minecraft_home}/mcrcon/mcrcon -H localhost -P ${minecraft_rcon_port} -p "${minecraft_rcon_password}" stop
while kill -0 $MAINPID 2>/dev/null; do
  sleep 0.5
done
EOF"
  sudo chmod 775 ${minecraft_home}/stop
  sudo chown ${minecraft_user}:${minecraft_group} ${minecraft_home}/stop

  if [ -f ${minecraft_home}/server.properties ]; then
    sudo rm ${minecraft_home}/server.properties
  fi
  sudo bash -c "cat <<EOF > ${minecraft_home}/server.properties
#Minecraft server properties
enable-jmx-monitoring=false
rcon.port=${minecraft_rcon_port}
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings=
level-name=minecraftLevel
motd=\u00A74Brand new\u00A77 Minecraft Server\u00A7r \u00A76\u00A7l!!!\u00A7r\n\u00A79Hosted\u00A7r on a \u00A7aRaspberry Pi
query.port=${minecraft_port}
pvp=true
generate-structures=true
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
max-players=5
use-native-transport=true
online-mode=false
enable-status=true
allow-flight=false
broadcast-rcon-to-ops=true
view-distance=10
max-build-height=256
server-ip=
allow-nether=true
server-port=${minecraft_port}
enable-rcon=true
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
resource-pack=
entity-broadcast-range-percentage=100
rcon.password=${minecraft_rcon_password}
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=true
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
snooper-enabled=true
function-permission-level=2
level-type=default
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=0
resource-pack-sha1=
max-world-size=29999984
EOF"
  sudo chmod 775 ${minecraft_home}/server.properties
  sudo chown ${minecraft_user}:${minecraft_group} ${minecraft_home}/server.properties

  if [ -f ${minecraft_home}/eula.txt ]; then
    sudo rm ${minecraft_home}/eula.txt
  fi
  sudo bash -c "cat <<EOF > ${minecraft_home}/eula.txt
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
eula=true
EOF"
  sudo chmod 775 ${minecraft_home}/eula.txt
  sudo chown ${minecraft_user}:${minecraft_group} ${minecraft_home}/eula.txt

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
    sudo bash -c "cat <<EOF > ${minecraft_service_path}
[Unit]
Description=start and stop the minecraft-server 

[Service]
User=minecraft
Group=minecraft
WorkingDirectory=/home/minecraft

Restart=on-failure
RestartSec=20 5

ExecStart=/home/minecraft/start
ExecStop=/home/minecraft/stop

[Install]
WantedBy=multi-user.target
EOF"
  fi

  sudo systemctl enable ${minecraft_service}
  sudo systemctl start ${minecraft_service}

  osuccess "Minecraft installed"
fi