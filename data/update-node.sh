#!/bin/bash

NEW_VERSION=$(curl -sL https://api.github.com/repos/origintrail/ot-node/releases/latest | jq -r .tag_name | sed 's|v||')
OLD_VERSION=$(ls -l /ot-node/current | awk '{print $11}' | sed 's|/ot-node/||')

if [[ -d "/ot-node/$NEW_VERSION" ]]; then
  echo "This node is already updated!"
  exit 2
fi

read -r -p "Updating requires having logged to this server as root. You CANNOT sudo into root due to OT bugs. Compiling will fail if the username you use to login is not root. Do you want to proceed? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "Proceeding with updating.."
        ;;
    *)
        exit 0
        ;;
esac

cd /ot-node/

echo "Downloading and preparing ot-node"
git clone -b release/mainnet https://github.com/OriginTrail/ot-node.git

mv /ot-node/ot-node /ot-node/$NEW_VERSION

rm /ot-node/current

ln -s /ot-node/$NEW_VERSION /ot-node/current

cp /ot-node/$OLD_VERSION/.origintrail_noderc /ot-node/current/
cp /ot-node/$OLD_VERSION/.env /ot-node/current


echo "Compiling the new node"
cd $NEW_VERSION
npm install

echo "Restarting the node to use the new version"
systemctl restart otnode

echo "Opening logs to verify startup was successful"
journalctl -u otnode -f | ccze -A
