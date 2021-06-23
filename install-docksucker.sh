#!/bin/bash

apt install -y build-essential gcc python-dev ccze

cd OT-DockSucker

./root/OT-DockSucker/data/install-otnode.sh

apt-mark hold arangodb3 nodejs

mkdir -p /ot-node && mv /root/OT-DockSucker/ot-node/ /ot-node/5.0.4

ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current

echo NODE_ENV=mainnet >> .env

#Smoothbrain
git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git

cd OT-Smoothbrain-Backup

cp /OT-DockerSucker/data/config.sh /root/Smoothbrain-Backup/config.sh

source /root/Smoothbrain-Backup/config.sh && ./restic snapshots -H <PUT_HOSTNAME_HERE>

./restic restore $(restic snapshots -H $HOSTNAME | grep $HOSTNAME | cut -c1-8 | tail -n 1) --target /root

mv /root/root/OT-Smoothbrain-Backup/backup/ /root/backup && rm -rf /root/root

sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": '"$ADDRESS"'|g' /root/backup/.origintrail_noderc

cp /root/backup/.origintrail_noderc /ot-node/current/

cd /ot-node/current

npm run setup

./scripts/update-arango-password.sh /root/.origintrail_noderc/mainnet/

cd /root/OT-DockSucker/data

./restore.sh

rm -rf /root/backup/arangodb

cp -r /root/backup/* /root/.origintrail_noderc/mainnet/

cp /root/OT-DockSucker/otnode.service /lib/systemd/system

systemctl enable otnode.service

systemctl start otnode
