#####################################################
# Created by cryptopool.builders-OLD-VERSION for crypto use...
#####################################################


source /etc/functions.sh
source /etc/multipool.conf
source $HOME/multipool/daemon_builder/.my.cnf
source $STORAGE_ROOT/daemon_builder/temp_coin_builds/.lastcoin.conf
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}

# Set what we need
now=$(date +"%m_%d_%Y")
set -e
NPROC=$(nproc)

# clean the build directory, that could be some of the permissions issue
make clean

# Re-running the permissions string even though it runs the first time, some coins who the hell knows why.
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/share/genbuild.sh
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/leveldb/build_detect_platform

# Build the coin under the proper configuration
if [[ ("$berkeley" == "4.8") ]]; then
echo "Building using Berkeley 4.8..."
basedir=$(pwd)
sh autogen.sh
./configure CPPFLAGS="-I${STORAGE_ROOT}/berkeley/db4/include -O2" LDFLAGS="-L${STORAGE_ROOT}/berkeley/db4/lib" --without-gui --disable-tests
else
echo "Building using Berkeley 5.3..."
basedir=$(pwd)
sh autogen.sh
./configure CPPFLAGS="-I${STORAGE_ROOT}/berkeley/db5/include -O2" LDFLAGS="-L${STORAGE_ROOT}/berkeley/db5/lib" --without-gui --disable-tests
fi
make -j$(nproc)

clear

# LS the SRC dir to have user input bitcoind and bitcoin-cli names
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/
find . -maxdepth 1 -type f \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
read -e -p "Please enter the coind name from the directory above, example bitcoind :" coind
read -e -p "Is there a coin-cli, example bitcoin-cli [y/N] :" ifcoincli

if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
read -e -p "Please enter the coin-cli name :" coincli
fi

clear

# Strip and copy to /usr/bin
sudo strip $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coind}
sudo cp $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coind} /usr/bin
if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
sudo strip $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coincli}
sudo cp $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coincli} /usr/bin
fi

# Make the new wallet folder have user paste the coin.conf and finally start the daemon
if [[ ! -e '$STORAGE_ROOT/wallets' ]]; then
sudo mkdir -p $STORAGE_ROOT/wallets
fi

sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/wallets
mkdir -p $STORAGE_ROOT/wallets/."${coind::-1}"
echo "I am now going to open nano, please copy and paste the config from yiimp in to this file."
read -n 1 -s -r -p "Press any key to continue"
sudo nano $STORAGE_ROOT/wallets/."${coind::-1}"/${coind::-1}.conf
clear
cd $HOME/multipool/daemon_builder
echo "Starting ${coind::-1}"
"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" -daemon -shrinkdebugfile

# If we made it this far everything built fine removing last coin.conf and build directory
sudo rm -r $STORAGE_ROOT/daemon_builder/temp_coin_builds/.lastcoin.conf
sudo rm -r $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}
sudo rm -r $HOME/multipool/daemon_builder/.my.cnf


clear
echo "Installation of ${coind::-1} is completed and running."
echo Type daemonbuilder at anytime to install a new coin!
exit
