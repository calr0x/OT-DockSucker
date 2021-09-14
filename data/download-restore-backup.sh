#!/bin/bash

echo "Restoring data from a ColdBrain backup to either a docker or dockerless node."

if [ -d "/ot-node" ]; then
  echo "Dockerless installation detected. Proceeding with a DockSucker cold-restore."
  RESTORETYPE=dockerless
else
  if [ -d "/var/lib/docker" ]; then
    echo "Docker installation detected. Proceeding with a Docker cold-restore."
    RESTORETYPE=docker
  fi
fi

echo "source /root/OT-Settings/config.sh"
source /root/OT-Settings/config.sh

echo "/root/OT-Smoothbrain-Backup/restic snapshots -H $HOSTNAME --tag coldbackup | grep $HOSTNAME | cut -c1-8 | tail -n 1"
SNAPSHOT=$(/root/OT-Smoothbrain-Backup/restic snapshots -H $HOSTNAME --tag coldbackup | grep $HOSTNAME | cut -c1-8 | tail -n 1)

if [[ $? -ne 0 ]]; then
  exit 1
fi

echo "Backup found!"
echo "******************************************"
echo "******************************************"
echo "******************************************"
echo "Writing the snapshot value $SNAPSHOT which was used to restore to /root/coldbrain-restore-log."
echo "You can delete this file at any time."
echo $SNAPSHOT >> /root/coldbrain-restore-log
echo "******************************************"
echo "******************************************"
echo "******************************************"

if [ $RESTORETYPE == "dockerless" ]; then
  systemctl stop otnode
  systemctl stop arangodb3
  /root/OT-Smoothbrain-Backup/restic restore $SNAPSHOT --target /

  if [[ $? -ne 0 ]]; then
    exit 1
  fi

  systemctl start arangodb3
  /root/OT-DockSucker/data/update-arango-password.sh /root/.origintrail_noderc/mainnet
  systemctl start otnode
else
  exit
  ln -s "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/" root/smoothbrain-temp
  rm -rf /var/lib arangodb3 /var/lib/arangodb3-apps
  /root/OT-Smoothbrain-Backup/restic restore $SNAPSHOT --target /root/smoothbrain-temp
  docker exec otnode ./scripts/update-arango-password.sh
  rm -rf /root/smoothbrain-temp
fi