#!/bin/bash

VERSION=$(lsb_release -sr)

if [ $VERSION != 18.04 ]; then
  echo "OT-DockSucker requires Ubuntu 18.04. Destroy this VPS and remake using Ubuntu 18.04."
  exit 1
fi

echo "apt install -y build-essential gcc python-dev ccze"
apt install -y build-essential gcc python-dev ccze
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cd /root"
cd /root
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cd OT-DockSucker/data"
cd OT-DockSucker/data
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "./install-otnode.sh"
./install-otnode.sh

echo "apt-mark hold arangodb3 nodejs"
apt-mark hold arangodb3 nodejs
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "mkdir -p /ot-node && mv /root/OT-DockSucker/data/ot-node/ /ot-node/5.0.4"
mkdir -p /ot-node && mv /root/OT-DockSucker/data/ot-node/ /ot-node/5.0.4
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current"
ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo NODE_ENV=mainnet >> .env
if [[ $? -ne 0 ]]; then
  exit 1
fi

#Smoothbrain
echo "cd /root"
cd /root
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git"
git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "source /root/OT-Settings/data/config.sh"
source /root/OT-Settings/data/config.sh

echo "/root/OT-Smoothbrain-Backup/restic snapshots --tag coldbackup -H $HOSTNAME | grep $HOSTNAME | cut -c1-8 | tail -n 1"
SNAPSHOT=$(/root/OT-Smoothbrain-Backup/restic snapshots -H $HOSTNAME | grep $HOSTNAME | cut -c1-8 | tail -n 1)
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "/root/OT-Smoothbrain-Backup/restic restore $SNAPSHOT --target /root"
echo "******************************************"
echo "******************************************"
echo "******************************************"
echo "Writing the snapshot value $SNAPSHOT which was used to restore to /root/dockerless-install-settings."
echo "You can delete this file at any time."
echo $SNAPSHOT >> dockerless-install-settings
echo "******************************************"
echo "******************************************"
echo "******************************************"
/root/OT-Smoothbrain-Backup/restic restore $SNAPSHOT --target /root
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cd /root"
cd /root
if [[ $? -ne 0 ]]; then
  exit 1
fi

ADDRESS=$(hostname -I | cut -f 1 -d ' ')
echo "******************************************"
echo "******************************************"
echo "******************************************"
echo $ADDRESS
echo "Writing IP address $ADDRESS value to /root/dockerless-install-settings."
echo "You can delete this file at any time."
echo $ADDRESS >> dockerless-install-settings
echo "******************************************"
echo "******************************************"
echo "******************************************"
sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": "'"$ADDRESS"'",|g' /ot-node/current/.origintrail_noderc
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cd /ot-node/current"
cd /ot-node/current
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "npm run setup"
npm run setup
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "/root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet"
/root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cp /root/OT-DockSucker/data/otnode.service /lib/systemd/system"
cp /root/OT-DockSucker/data/otnode.service /lib/systemd/system
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "systemctl enable otnode.service"
systemctl enable otnode.service
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "Adding firewall rules 22, 3000, 5278, and 8900, and enabling the firewall"
ufw allow 22/tcp && ufw allow 3000 && ufw allow 5278 && ufw allow 8900 && ufw enable

#echo "The IP address used to configure .origintral_noderc is $ADDRESS."
echo "The SmoothBrain snapshot used to restore the data on this node was $SNAPSHOT."

echo "Setting the logs to have a hard limit of 50 meg. Log deletions/clearing will not be required..."
sed -i 's|#SystemMaxUse=|SystemMaxUse=50M|' /etc/systemd/journald.conf
systemctl restart systemd-journald

nano /ot-node/current/.origintrail_noderc
#echo "Starting the node"
#systemctl start otnode

#echo "Displaying the logs on strtup. Exit using ctrl+c at any time. The node will continue to run."
#journalctl -u otnode -f | ccze -A
