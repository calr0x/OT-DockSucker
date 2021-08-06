#!/bin/bash

IS_UPDATED=$(find /ot-node -name 5.1.0 -type d | wc -l)

if [[$IS_UPDATED -eq 1 ]]; then
  echo "This node is already updated!"
  exit 1
fi

systemctl stop otnode

#NEW_VERSION=$(curl -sL https://api.github.com/repos/origintrail/ot-node/releases/latest | jq -r .tag_name)
#OLD_VERSION=Whaever the original dir was named

cd /ot-node

git clone https://github.com/OriginTrail/ot-node.git

mv ot-node 5.1.0

rm current

ln -s 5.1.0 current

cd current

cp /ot-node/5.0.4/.origintrail_noderc /ot-node/current/
cp /ot-node/5.0.4/.env /ot-node/current

npm install

systemctl start otnode

journalctl -u otnode -f | ccze -A