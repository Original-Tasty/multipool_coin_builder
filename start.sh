#!/usr/bin/env bash
#####################################################
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders-OLD-VERSION for crypto use...
#####################################################

source /etc/functions.sh # load our functions
source /etc/multipool.conf

cd $HOME/multipool/daemon_builder
# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

if ! locale -a | grep en_US.utf8 > /dev/null; then
# Generate locale if not exists
hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

# Create the temporary installation directory if it doesn't already exist.
echo Creating the temporary build folder...
if [ ! -d $STORAGE_ROOT/daemon_builder/temp_coin_builds ]; then
sudo mkdir -p $STORAGE_ROOT/daemon_builder
sudo mkdir -p $STORAGE_ROOT/daemon_builder/temp_coin_builds
fi
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/daemon_builder

message_box "Ultimate Crypto-Server bunbunbunbunbunny  Daemon Installer" \
"Warning! This version of the daemon installer only works with servers setup with the Ultimate Crypto-Server Installer!
\n\nSetup for the most part is fully automated. Very little user input is required."

# Start the installation.
source menu.sh

clear
echo Installation of your coin daemon is completed.
echo Type daemonbuilder at anytime to install a new coin!
