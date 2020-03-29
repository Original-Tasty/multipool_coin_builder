#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by cryptopool.builders-OLD-VERSION for crypto use...
#####################################################

source /etc/functions.sh
cd $HOME/multipool/daemon_builder

RESULT=$(dialog --stdout --title "Ultimate Crypto-Server Daemon Installer" --menu "Choose one" -1 60 4 \
1 "Install Berkeley 4.x Coin with autogen file" \
2 "Install Berkeley 5.x Coin with autogen file" \
3 "Install Coin with makefile.unix file" \
4 Exit)
if [ $RESULT = ]
then
exit;
fi

if [ $RESULT = 1 ]
then
clear;
echo '
autogen=true
berkeley="4.8"
' | sudo -E tee $HOME/multipool/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 2 ]
then
clear;
echo '
autogen=true
berkeley="5.3"
' | sudo -E tee $HOME/multipool/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 3 ]
then
clear;
echo '
autogen=false
' | sudo -E tee $HOME/multipool/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 4 ]
then
clear;
exit;
fi
