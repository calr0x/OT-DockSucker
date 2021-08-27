#!/bin/bash

if [[ -d "/ot-node/5.1.0" ]]; then
  echo "This node is already updated!"
  exit 1
fi

systemctl stop otnode

#NEW_VERSION=$(curl -sL https://api.github.com/repos/origintrail/ot-node/releases/latest | jq -r .tag_name)
#OLD_VERSION=Whaever the original dir was named

cd /ot-node/

git clone -b release/mainnet https://github.com/OriginTrail/ot-node.git

mv /ot-node/ot-node /ot-node/5.1.0

rm /ot-node/current

ln -s /ot-node/5.1.0 /ot-node/current

cd current

cp /ot-node/5.0.4/.origintrail_noderc /ot-node/current/
cp /ot-node/5.0.4/.env /ot-node/current

npm install

systemctl start otnode

journalctl -u otnode -f | ccze -A
