#!/bin/bash


##############################
#
# BEFORE RUNNING THIS SCRIPT, READ THE FOLLOWING INSTRUCTIONS CAREFULLY :
#
# This script will help you transition from your full docker node to a new dockerless node
#
# These are the main steps :
# 1. Create a brand new virtual server with your VPS provider
# 2. Transfer your old server's docker files directly to that new server
# 3. Use this restore script to restore your node to a new dockerless node
#
# BEFORE RUNNING THIS SCRIPT, YOU MUST DO THE FOLLOWING :
# 1. Create a brand new server
# 2. On your old server, type the following : docker exec otnode supervisorctl stop all
# 3. Test the connection between your old and new server. On your new server, type : ssh OLD_SERVER_IP
# 4. if connection is successful, exit connection
# 5. Change OLD_SERVER_IP parameter right below, save and exit the script (ctrl+s, ctrl+x) and you can now run this script :)
#
##############################

OLD_HOST=OLD_SERVER_IP
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

echo "mkdir -p /ot-node && mv /root/OT-DockSucker/data/ot-node/ /ot-node/5.1.0"
mkdir -p /ot-node && mv /root/OT-DockSucker/data/ot-node/ /ot-node/5.1.0
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "ln -s /ot-node/5.1.0 /ot-node/current && cd /ot-node/current"
ln -s /ot-node/5.1.0 /ot-node/current && cd /ot-node/current
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo NODE_ENV=mainnet >> .env
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cd /root"
cd /root
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "mkdir /root/backup"
mkdir /root/backup
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "Copying files from old server"
ssh root@$OLD_HOST scp root@$OLD_HOST:.origintrail_noderc /root/backup && scp root@$OLD_HOST:$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/ot-node/data /root/backup && scp root@$OLD_HOST:$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/var/lib/arangodb3 /root/backup && scp root@$OLD_HOST:$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/var/lib/arangodb3-apps /root/backup
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cp -r /root/backup/.origintrail_noderc /ot-node/current"
cp -r /root/backup/.origintrail_noderc /ot-node/current/
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "rm -rf /var/lib/arangodb3"
rm -rf /var/lib/arangodb3
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "rm -rf /var/lib/arangodb3-apps"
rm -rf /var/lib/arangodb3-apps
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cp -r /root/backup/arango* /var/lib/"
cp -r /root/backup/arango* /var/lib/
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "/root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet"
/root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet
if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "cp -r /root/backup/data/* /root/.origintrail_noderc/mainnet/"
cp -r /root/backup/data/* /root/.origintrail_noderc/mainnet/
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
ufw allow 22/tcp && ufw allow 3000 && ufw allow 5278 && ufw allow 8900 && ufw enable

echo "Setting the logs to have a hard limit of 50 meg. Log deletions/clearing will not be required..."
sed -i 's|#SystemMaxUse=|SystemMaxUse=50M|' /etc/systemd/journald.conf
systemctl restart systemd-journald


echo "Your Dockerless otnode is ready to run ! Please verify that the hostname on the config is correct with nano /ot-node/current/.origintrail_noderc. 
Once you are done, run systemctl start otnode to start the node and journalctl -u otnode -f | ccze -A to check the logs"

# nano /ot-node/current/.origintrail_noderc
#echo "Starting the node"
#systemctl start otnode

#echo "Displaying the logs on strtup. Exit using ctrl+c at any time. The node will continue to run."
#journalctl -u otnode -f | ccze -A
