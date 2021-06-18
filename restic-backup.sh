#!/bin/bash
#
source "/root/OT-Smoothbrain-Backup/config.sh"
STATUS=$?
N1=$'\n'

echo "Backing up OT Node data"
node /otnode/current/scripts/backup.js --config=/ot-node/current/.origintrail_noderc --configDir=.origintrail_noderc/mainnet --backupDirectory=/root/backup  2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "OT docker backup command FAILED"
  exit 1
fi

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup /root/OT-Smoothbrain-Backup/backup/.origintrail_noderc /root/OT-Smoothbrain-Backup/backup/* 2>&1)
echo $OUTPUT
if [ $? -eq 0 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/OT-Smoothbrain-Backup/backup/* /root/OT-Smoothbrain-Backup/backup/.origintrail_noderc
else
  /root/OT-Smoothbrain-Backup/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  exit 1
fi

exit 0
