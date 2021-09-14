#!/bin/bash
source "/root/OT-Settings/config.sh"
STATUS=$?
N1=$'\n'

if [ -d "/root/backup" ]; then
  echo "Deleting existing backup folder"
  rm -rf /root/backup
fi

echo "Linking container backup folder to /root/backup"
ln -sf "$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' otnode)/ot-node/backup" /root/backup

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Linking container backup folder command FAILED"
  exit 1
fi

echo "Deleting any exiting backups inside container"
rm -rf /root/backup/*

echo "Backing up OT Node data"
docker exec otnode node scripts/backup.js --config=/ot-node/.origintrail_noderc --configDir=/ot-node/data --backupDirectory=/ot-node/backup  2>&1

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "OT docker backup command FAILED"
  exit 1
fi

echo "Moving data out of dated folder into backup"
mv -v /root/backup/202*/* /root/backup/ 2>&1

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Moving data command FAILED"
  exit 1
fi

echo "Moving hidden data out of dated folder into backup"
mv -v /root/backup/*/.origintrail_noderc /root/backup/ 2>&1

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Moving hidden data command FAILED"
  exit 1
fi

echo "Deleting dated folder"
rm -rf /root/backup/202* 2>&1

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Deleting data folder command FAILED"
  exit 1
fi

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup /root/backup/.origintrail_noderc /root/backup/* 2>&1)
RESTIC_SUCCESS=$?
echo $OUTPUT
if [ $RESTIC_SUCCESS -eq 0 ]; then
  /root/OT-Settings/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
  rm -rf /root/backup/*
else
  /root/OT-Settings/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  exit 1
fi

exit 0
