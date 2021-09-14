#!/bin/bash
source "/root/OT-Settings/config.sh"
N1=$'\n'

echo "Removing outdated snapshots and data"

FORGET_OUTPUT=`/root/OT-Smoothbrain-Backup/restic forget --group-by host --keep-last 1 2>&1`
FORGET_STATUS=$?
echo "$FORGET_OUTPUT"

echo "Notifying result of forget command with telegram STATUS=$FORGET_STATUS"

if [ $FORGET_STATUS -eq 0 ]; then
  /root/OT-Settings/data/send.sh "Forget command SUCCEEDED"
else
  /root/OT-Settings/data/send.sh "Forget command FAILED${N1}$FORGET_OUTPUT"
  exit 1
fi

PRUNE_OUTPUT=`/root/OT-Smoothbrain-Backup/restic prune` 2>&1
PRUNE_SUCCESS_OUTPUT=$(echo "$PRUNE_OUTPUT" | grep 'total\ prune\|remaining:')
PRUNE_STATUS=$?

if [ $PRUNE_STATUS -eq 0 ]; then
  /root/OT-Settings/data/send.sh "Prune command SUCCEEDED${N1}$PRUNE_SUCCESS_OUTPUT"
else
  /root/OT-Settings/data/send.sh "Prune command FAILED${N1}$PRUNE_OUTPUT"
  exit 1
fi

CHECK_OUTPUT=`/root/OT-Smoothbrain-Backup/restic check 2>&1`

if [ $? -eq 0 ]; then
  /root/OT-Settings/data/send.sh "Check command SUCCEEDED"
else
  /root/OT-Settings/data/send.sh "Check command FAILED${N1}$CHECK_OUTPUT"
  exit 1
fi
