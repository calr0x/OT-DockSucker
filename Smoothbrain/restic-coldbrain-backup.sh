#!/bin/bash

# This only works on dockerless nodes !
# This will stop the node and then the arangodb server, backup any changed data directly from the arango folder, and then restart arango, and then the node.
# The initial backup will take some time!

source "/root/OT-Settings/config.sh"
STATUS=$?
N1=$'\n'

echo "Stopping otnode"
systemctl stop otnode

if [[ $? -ne 0 ]]; then
  /root/OT-Settings/data/send.sh "Stopping otnode service failed during backup."
fi

echo "Stopping arangodb3"
systemctl stop arangodb3

if [[ $? -ne 0 ]]; then
  /root/OT-Settings/data/send.sh "Stopping arangodb3 service failed during backup."
fi

echo "Uploading data to backup server"

OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup --tag coldbackup /ot-node/current/.origintrail_noderc /root/.origintrail_noderc /var/lib/arangodb3 /var/lib/arangodb3-apps 2>&1)

if [[ $? -eq 0 ]]; then
  if [[ $SMOOTHBRAIN_NOTIFY_ON_SUCCESS == "" ]]; then
    SMOOTHBRAIN_NOTIFY_ON_SUCCESS="true"
  fi
  if [[ $SMOOTHBRAIN_NOTIFY_ON_SUCCESS == "true" ]]; then
    /root/OT-Settings/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  fi
else
  /root/OT-Settings/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  systemctl start arangodb3
  
  if [[ $? -ne 0 ]]; then
    /root/OT-Settings/data/send.sh "Starting arangodb3 service failed during backup."
  fi
  systemctl start otnode
  
  if [[ $? -ne 0 ]]; then
    /root/OT-Settings/data/send.sh "Starting otnode service failed during backup."
  fi
  
  exit 1
fi

echo "Starting otnode and arangodb3"
systemctl start arangodb3

if [[ $? -ne 0 ]]; then
  /root/OT-Settings/data/send.sh "Starting arangodb3 service failed during backup."
  exit 1
fi

systemctl start otnode

if [[ $? -ne 0 ]]; then
  /root/OT-Settings/data/send.sh "Starting otnode service failed during backup."
  exit 1
fi

exit 0
