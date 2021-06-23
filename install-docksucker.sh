#!/bin/bash
echo "apt install -y build-essential gcc python-dev ccze"
apt install -y build-essential gcc python-dev ccze

echo "cd data"
cd data

echo "./install-otnode.sh"
./install-otnode.sh

echo "apt-mark hold arangodb3 nodejs"
apt-mark hold arangodb3 nodejs

echo "mkdir -p /ot-node && mv /root/OT-DockSucker/data/ot-node/ /ot-node/5.0.4"
mkdir -p /ot-node && mv /root/OT-DockSucker/data/ot-node/ /ot-node/5.0.4

echo "ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current"
ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current

echo NODE_ENV=mainnet >> .env

#Smoothbrain
echo "cd /root"
cd /root

echo "git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git"
git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git

#echo "mv /root/OT-DockSucker/OT-Smoothbrain-Backup /root"
#mv /root/OT-DockSucker/OT-Smoothbrain-Backup /root

echo "cp /root/OT-DockSucker/data/config.sh /root/OT-Smoothbrain-Backup/config.sh"
cp /root/OT-DockSucker/data/config.sh /root/OT-Smoothbrain-Backup/config.sh

echo "source /root/OT-Smoothbrain-Backup/config.sh"
source /root/OT-Smoothbrain-Backup/config.sh

echo "/root/OT-Smoothbrain-Backup/restic snapshots -H $HOSTNAME | grep $HOSTNAME | cut -c1-8 | tail -n 1"
SNAPSHOT=$(/root/OT-Smoothbrain-Backup/restic snapshots -H $HOSTNAME | grep $HOSTNAME | cut -c1-8 | tail -n 1)

echo "/root/OT-Smoothbrain-Backup/restic restore $SNAPSHOT --target /root"
/root/OT-Smoothbrain-Backup/restic restore $SNAPSHOT --target /root

echo "cd /root"
cd /root

echo "mv /root/root/OT-Smoothbrain-Backup/backup/ /root/backup && rm -rf /root/root"
mv /root/root/OT-Smoothbrain-Backup/backup/ /root/backup && rm -rf /root/root

echo "cp /root/backup/.origintrail_noderc /ot-node/current/"
cp /root/backup/.origintrail_noderc /ot-node/current/

ADDRESS=$(hostname -I | cut -f 1 -d ' ')
echo "sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": '"$ADDRESS"'|g' /root/backup/.origintrail_noderc"
sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": "'"$ADDRESS"'",|g' /ot-node/current/.origintrail_noderc

echo "cd /ot-node/current"
cd /ot-node/current

echo "npm run setup"
npm run setup

echo "/root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet"
/root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet

echo "cd /root/OT-DockSucker/data"
cd /root/OT-DockSucker/data

echo "./restore.sh"
./restore.sh

echo "rm -rf /root/backup/arangodb"
rm -rf /root/backup/arangodb

echo "cp -r /root/backup/* /root/.origintrail_noderc/mainnet/""
cp -r /root/backup/* /root/.origintrail_noderc/mainnet/

echo "cp /root/OT-DockSucker/otnode.service /lib/systemd/system"
cp /root/OT-DockSucker/otnode.service /lib/systemd/system

echo "systemctl enable otnode.service"
systemctl enable otnode.service

#echo systemctl start otnode
#systemctl start otnode
