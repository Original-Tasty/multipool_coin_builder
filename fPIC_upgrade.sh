#####################################################
# Created by cryptopool.builders-OLD-VERSION for crypto use...
#####################################################

clear

source /etc/functions.sh
source /etc/multipool.conf
source $HOME/multipool/daemon_builder/.my.cnf
source $STORAGE_ROOT/daemon_builder/temp_coin_builds/.lastcoin.conf
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}

# Set what we need
now=$(date +"%m_%d_%Y")
set -e
NPROC=$(nproc)

#get the coind name one more time since we dont store it
read -e -p "Enter the coind name as it is in yiimp, example bitcoind : " pkillcoin

# re-run autogen file
sh autogen.sh
if [[ ! -e '$STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/share/genbuild.sh' ]]; then
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/share/genbuild.sh
fi
if [[ ! -e '$STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/leveldb/build_detect_platform' ]]; then
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/leveldb/build_detect_platform
fi
# Build the coin under the proper configuration adding openSSL location
if [[ ("$berkeley" == "4.8") ]]; then
./configure CPPFLAGS="-I${STORAGE_ROOT}/berkeley/db4/include -O2 -fPIC" LDFLAGS="-L${STORAGE_ROOT}/berkeley/db4/lib" --without-gui --disable-tests
else
./configure CPPFLAGS="-I${STORAGE_ROOT}/berkeley/db5/include -O2 -fPIC" LDFLAGS="-L${STORAGE_ROOT}/berkeley/db5/lib" --without-gui --disable-tests
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
sudo pkill -9 ${pkillcoin}
sudo strip $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coind}
sudo cp $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coind} /usr/bin
if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
sudo strip $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coincli}
sudo cp $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}/src/${coincli} /usr/bin
fi

# Have user verify con.conf file and start coin
echo "I am now going to open nano, please verify if there any changes that are needed such as adding or removing addnodes."
read -n 1 -s -r -p "Press any key to continue"
sudo nano $STORAGE_ROOT/wallets/."${coind::-1}"/${coind::-1}.conf
clear
cd $HOME/multipool/daemon_builder
echo "Starting ${coind::-1}"
"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" -daemon -shrinkdebugfile -reindex

# If we made it this far everything built fine removing last coin.conf and build directory
sudo rm -r $STORAGE_ROOT/daemon_builder/temp_coin_builds/.lastcoin.conf
sudo rm -r $STORAGE_ROOT/daemon_builder/temp_coin_builds/${lastcoin}
sudo rm -r $HOME/multipool/daemon_builder/.my.cnf


clear
echo "Upgrade of ${coind::-1} is completed and running. The blockchain is being reindexed, it could be several minutes before you can connect to your coin."
echo Type daemonbuilder at anytime to install a new coin!
