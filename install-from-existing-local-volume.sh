#!/bin/bash

# This script assumes that:
# you are running a fresh server on Ubuntu 18.04
# you have a restic backup ready to restore on your Amazon AWS

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

echo "Temporarily enable 1gig swap file"
fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

echo "cd data"
cd data
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

echo "source /root/OT-Settings/config.sh"
source /root/OT-Settings/config.sh

echo "cp /root/backup/.origintrail_noderc /ot-node/current/"
cp /root/backup/.origintrail_noderc /ot-node/current
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

echo "cd /root/OT-DockSucker/data"
cd /root/OT-DockSucker/data
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "./restore.sh"
./restore.sh
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "rm -rf /root/backup/arangodb"
rm -rf /root/backup/arangodb
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cp -r /root/backup/* /root/.origintrail_noderc/mainnet/"
cp -r /root/backup/* /root/.origintrail_noderc/mainnet/
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "rm -rf /root/backup"
rm -rf /root/backup
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
ufw allow 22/tcp && ufw allow 3000 && ufw allow 5278 && ufw allow 8900 && yes | ufw enable

#echo "The IP address used to configure .origintral_noderc is $ADDRESS."
echo "The SmoothBrain snapshot used to restore the data on this node was $SNAPSHOT."

#ADDRESS=$(hostname -I | cut -f 1 -d ' ');sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": "'"$ADDRESS"'",|g' /ot-node/current/.origintrail_noderc
ADDRESS=$(hostname -I | cut -f 1 -d ' ')
cat /ot-node/current/.origintrail_noderc | jq ".network.hostname = \"$ADDRESS\"" >> /ot-node/current/origintrail_noderc
mv /ot-node/current/origintrail_noderc /ot-node/current/.origintrail_noderc

echo "Removing swapfile"
swapoff /swapfile && rm /swapfile

echo "Setting the logs to have a hard limit of 50 meg. Log deletions/clearing will not be required..."
sed -i 's|#SystemMaxUse=|SystemMaxUse=50M|' /etc/systemd/journald.conf
systemctl restart systemd-journald

echo "Your Dockerless otnode is ready to run ! Please very that the hostname on the config is correct with nano /ot-node/current/.origintrail_noderc. 
Once you are done, run systemctl start otnode to start the node and journalctl -u otnode -f | ccze -A to check the logs"

#nano /ot-node/current/.origintrail_noderc

#echo "Starting the node"
#systemctl start otnode

#echo "Displaying the logs on strtup. Exit using ctrl+c at any time. The node will continue to run."
#journalctl -u otnode -f | ccze -A
