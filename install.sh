#/bin/sh
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

# we do not expect to fail!
FAILED=0

# script requires root
if [ $(id -u) -ne 0 ]; then
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
cp -r boot/. "$BOOT_DIR" || FAILED=1
if [ $FAILED -ne 0 ]; then echo "Failed to install in $BOOT_DIR"; exit 1; fi
cp -r lib/. "$LIB_DIR" || FAILED=1
if [ $FAILED -ne 0 ]; then echo "Failed to install in $LIB_DIR"; exit 1; fi

echo
echo "Installation successful. Reboot for changes to take effect."
