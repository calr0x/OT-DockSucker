#!/bin/bash

source "/root/OT-Settings/config.sh"
STATUS=$?
N1=$'\n'
BACKUPDIR=/root/backup

if [ -d "$BACKUPDIR" ]; then
  echo "Deleting existing backup folder contents"
  rm -rf $BACKUPDIR/* $BACKUPDIR/.origintrail_noderc
else
  mkdir -p $BACKUPDIR
fi

cd /ot-node/current

echo "Backing up OT Node data"
OUTPUT=$(node /ot-node/current/scripts/backup.js --config=/ot-node/current/.origintrail_noderc --configDir=/root/.origintrail_noderc/mainnet --backup_directory=$BACKUPDIR 2>&1 )

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "OT backup command FAILED:${N1}$OUTPUT"
  echo "$OUTPUT"
  exit 1
fi
echo "Success!"

echo "Moving data out of dated folder into backup"
OUTPUT=$(mv -v $BACKUPDIR/202*/* $BACKUPDIR/ 2>&1)

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Moving data command FAILED::${N1}$OUTPUT"
  echo "$OUTPUT"
  exit 1
fi
echo "Success!"

echo "Moving hidden data out of dated folder into backup"
OUTPUT=$(mv -v $BACKUPDIR/*/.origintrail_noderc $BACKUPDIR/ 2>&1)

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Moving hidden data command FAILED:${N1}$OUTPUT"
  echo "$OUTPUT"
  exit 1
fi
echo "Success!"

echo "Deleting dated folder"
OUTPUT=$(rm -rf $BACKUPDIR/202* 2>&1)

if [ $? -eq 1 ]; then
  /root/OT-Settings/data/send.sh "Deleting data folder command FAILED:${N1}$OUTPUT"
  echo "$OUTPUT"
  exit 1
fi
echo "Success!"

echo "Uploading data to Amazon S3"
OUTPUT=$(/root/OT-Smoothbrain-Backup/restic backup $BACKUPDIR/.origintrail_noderc $BACKUPDIR/* 2>&1)

if [ $? -eq 0 ]; then
  if [ $SMOOTHBRAIN_NOTIFY_ON_SUCCESS == "" ]; then
    $SMOOTHBRAIN_NOTIFY_ON_SUCCESS="true"
  fi
  if [ $SMOOTHBRAIN_NOTIFY_ON_SUCCESS == "true" ]; then
    /root/OT-Settings/data/send.sh "Backup SUCCESSFUL:${N1}$OUTPUT"
    echo "Deleting the backup directory"
    rm -rf $BACKUPDIR
  fi
else
  /root/OT-Settings/data/send.sh "Uploading backup to S3 FAILED:${N1}$OUTPUT"
  echo "$OUTPUT"
  exit 1
fi
echo $OUTPUT
echo "Success!"

exit 0
