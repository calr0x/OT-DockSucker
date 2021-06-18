#!/bin/bash
source "/root/OT-Smoothbrain-Backup/config.sh"
STATUS=$?
N1=$'\n'

rm -rf /root/OT-Smoothbrain-Backup/backup/* /root/OT-Smoothbrain-Backup/backup/.origintrail_noderc
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Delete backup folder contents FAILED"
  exit 1
fi

echo "Linking container backup folder to /root/OT-Smoothbrain-Backup/backup"
ln -sf "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/ot-node/backup" /root/OT-Smoothbrain-Backup/
echo $STATUS
if [ $STATUS == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Linking container backup folder command FAILED"
  exit 1
fi


echo "Backing up OT Node data"
docker exec otnode node scripts/backup.js --config=/ot-node/.origintrail_noderc --configDir=/ot-node/data --backupDirectory=/ot-node/backup  2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "OT docker backup command FAILED"
  exit 1
fi

echo "Moving data out of dated folder into backup"
mv -v /root/OT-Smoothbrain-Backup/backup/202*/* /root/OT-Smoothbrain-Backup/backup/ 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Moving data command FAILED"
  exit 1
fi

echo "Moving hidden data out of dated folder into backup"
mv -v /root/OT-Smoothbrain-Backup/backup/*/.origintrail_noderc /root/OT-Smoothbrain-Backup/backup/ 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Moving hidden data command FAILED"
  exit 1
fi


echo "Deleting dated folder"
rm -rf /root/OT-Smoothbrain-Backup/backup/202* 2>&1
echo $?
if [ $? == 1 ]; then
  /root/OT-Smoothbrain-Backup/data/send.sh "Deleting data folder command FAILED"
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
