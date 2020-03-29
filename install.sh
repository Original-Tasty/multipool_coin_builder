#!/usr/bin/env bash
#####################################################
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders-OLD-VERSION for crypto use...
#####################################################

source /etc/functions.sh # load our functions
source /etc/multipool.conf

echo '
#!/usr/bin/env bash
source /etc/functions.sh # load our functions
source /etc/multipool.conf
cd $HOME/multipool/daemon_builder
bash start.sh
cd ~
' | sudo -E tee /usr/bin/daemonbuilder >/dev/null 2>&1
sudo chmod +x /usr/bin/daemonbuilder

cd $HOME/multipool/daemon_builder
source start.sh
