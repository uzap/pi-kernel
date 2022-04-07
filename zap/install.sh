#!/bin/sh
# NEVER RUN A SCRIPT AS ROOT WITHOUT INSPECTING IT FIRST!
# AND REMEMBER TO KEEP A BACKUP!

# The directory structure for ZapPi kernel packages allows
# for the files to be dropped right into the base /boot and
# /lib directories. A custom installation might have to
# adjust where these directories are with the following
# variables.

# kernel & device trees base install directory
BOOT_DIR="/boot"

# modules base install directory
# some (older/Raspbian) systems retain this file structure
LIB_DIR="/lib"

# script requires root
if [ "$(id -u)" -ne 0 ]; then
  echo
  echo "Need root permission to run."
  echo "Please inspect the file and run with sudo."
  exit 1
fi

# exit if directories do not exist
if [ ! -d $BOOT_DIR ]; then
  echo
  echo "Directory $BOOT_DIR not found. Installation failed."
  exit 1
elif [ ! -d $LIB_DIR ]; then
  echo
  echo "Directory $LIB_DIR not found. Installation failed."
  exit 1
fi

# newer RasPiOS systems symlink from /usr
if [ $LIB_DIR = "/lib" ] && [ -L $LIB_DIR ]; then
  LIB_DIR="/usr/lib"
fi

# install the files, exit on failure
echo "Installing kernel to $BOOT_DIR & modules to $LIB_DIR..."
cp -r boot/. "$BOOT_DIR" || (echo "Failed to install in $BOOT_DIR" && exit 1)
cp -r lib/. "$LIB_DIR" || (echo "Failed to install in $LIB_DIR" && exit 1)

# comment out raspi-config ondemand tuning
if [ -f /etc/init.d/raspi-config ]; then
  if [ ! -f /etc/init.d/.raspi-config ]; then
    echo
    echo "Backing up old raspi-config as /etc/init.d/.raspi-config..."
    cp /etc/init.d/raspi-config /etc/init.d/.raspi-config
    echo "To restore, run:"
    echo "  sudo cp /etc/init.d/.raspi-config /etc/init.d/raspi-config"
  fi
  echo
  echo "Commenting out RasPiOS changes to ondemand cpufreq governor, if needed..."
  sed -i '/up_threshold/s/^#*/#/' /etc/init.d/raspi-config
  sed -i '/sampling_rate/s/^#*/#/' /etc/init.d/raspi-config
  sed -i '/sampling_down_factor/s/^#*/#/' /etc/init.d/raspi-config
fi

echo
echo "Installation successful. Reboot for changes to take effect."
