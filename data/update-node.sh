#!/bin/bash

NEW_VERSION=$(curl -sL https://api.github.com/repos/origintrail/ot-node/releases/latest | jq -r .tag_name | sed 's|v||')
OLD_VERSION=$(ls -l /ot-node/current | awk '{print $11}' | sed 's|/ot-node/||')

if [[ -d "/ot-node/$NEW_VERSION" ]]; then
  echo "This node is already updated!"
  exit 2
fi

cd /ot-node/

git clone -b release/mainnet https://github.com/OriginTrail/ot-node.git

mv /ot-node/ot-node /ot-node/$NEW_VERSION

rm /ot-node/current

ln -s /ot-node/$NEW_VERSION /ot-node/current

cd current

cp /ot-node/$OLD_VERSION/.origintrail_noderc /ot-node/current/
cp /ot-node/$OLD_VERSION/.env /ot-node/current

npm install

systemctl restart otnode

journalctl -u otnode -f | ccze -A