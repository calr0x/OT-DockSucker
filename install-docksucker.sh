#!/bin/bash

cd
apt update && apt upgrade -y && apt install -y build-essential gcc python-dev git ccze
git clone https://github.com/calr0x/OT-DockSucker.git && cd OT-DockSucker
./install.sh
apt-mark hold arangodb3 nodejs
mkdir -p /ot-node && mv /root/OT-DockSucker/ot-node/ /ot-node/5.0.4
ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current
echo NODE_ENV=mainnet >> .env
source /root/Smoothbrain-Backup/config.sh && ./restic snapshots -H <PUT_HOSTNAME_HERE>
./restic restore <PUT_SNAPSHOT_ID_HERE> --target /root
mv /root/root/OT-Smoothbrain-Backup/backup/ /root/backup && rm -rf /root/root
sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": '"$ADDRESS"'|g' /root/backup/.origintrail_noderc
cp /root/backup/.origintrail_noderc /ot-node/current/
cd /ot-node/current
npm run setup
./scripts/update-arango-password.sh /root/.origintrail_noderc/mainnet/
cd /root/OT-DockSucker
./restore.sh
rm -rf /root/backup/arangodb
cp -r /root/backup/* /root/.origintrail_noderc/mainnet/
cp /root/OT-DockSucker/otnode.service /lib/systemd/system
systemctl enable otnode.service
systemctl start otnode
