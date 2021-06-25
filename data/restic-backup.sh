#!/bin/bash
#
source "/root/OT-Smoothbrain-Backup/config.sh"
STATUS=$?
N1=$'\n'

ln -s /ot-node/backup /root/backup

cd /ot-node/current

echo "Backing up OT Node data"
node /ot-node/current/scripts/backup.js --config=/ot-node/current/.origintrail_noderc --configDir=/root/.origintrail_noderc/mainnet --backupDirectory=/root/backup  2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "OT docker backup command FAILED"
  exit 1
fi

echo "Moving data out of dated folder into backup"
mv -v /root/backup/202*/* /root/backup/ 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Moving data command FAILED"
  exit 1
fi

echo "Moving hidden data out of dated folder into backup"
mv -v /root/backup/*/.origintrail_noderc /root/backup/ 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Moving hidden data command FAILED"
  exit 1
fi


echo "Deleting dated folder"
rm -rf /root/backup/202* 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Deleting data folder command FAILED"
  exit 1
fi

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup /root/backup/.origintrail_noderc /root/backup/* 2>&1)
echo $OUTPUT
if [ $? -eq 0 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/backup/* /root/backup/.origintrail_noderc
else
  /root/OT-Smoothbrain-Backup/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  exit 1
fi

exit 0
