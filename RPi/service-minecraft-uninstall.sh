#!/usr/bin/env bash

. ./service-minecraft.sh --source-only

omain "Uninstalling Minecraft Service"

oprint "Stopping Minecraft Service"
sudo systemctl stop ${minecraft_service}

# getent passwd ${minecraft_user} > /dev/null
id ${minecraft_user} &>/dev/null
if [ $? -ne 0 ]; then
  owarning "User \"${minecraft_user}\" does not exist"
else
  oprint "Deleting user \"${minecraft_user}\""
  # sudo deluser --remove-home ${minecraft_user}
fi

grep -q ${minecraft_group} /etc/group &>/dev/null
if [ $? -ne 0 ]; then
  owarning "Group \"${minecraft_group}\" does not exist"
else
  oprint "Deleting group \"${minecraft_group}\""
  # sudo delgroup ${minecraft_group}
fi

if [ ! -f "${minecraft_service_path}" ]; then
  owarning "Service \"${minecraft_service_path}\" does not exist"
else
  oprint "Stopping and deleting service \"${minecraft_service_path}\""
  sudo systemctl stop ${minecraft_service}
  sudo systemctl disable ${minecraft_service}
  sudo rm ${minecraft_service_path}
fi

osuccess "Uninstalled Minecraft Service"
