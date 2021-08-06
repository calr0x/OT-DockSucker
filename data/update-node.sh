#!/bin/bash
#
systemctl stop otnode

NEW_VERSION=$(curl -sL https://api.github.com/repos/origintrail/ot-node/releases/latest | jq -r .tag_name)
OLD_VERSION=Whaever the original dir was named

cd /ot-node/

git clone https://github.com/OriginTrail/ot-node.git

mv /ot-node/ot-node /ot-node/$VERSION

rm /root/current

ln -s /ot-node/$VERSION /ot-node/current

cd current

cp /ot-node/$OLD_VERSION/.origintrail_noderc /ot-node/current/
cp ../5.0.4/.env .

npm install

systemctl start otnode