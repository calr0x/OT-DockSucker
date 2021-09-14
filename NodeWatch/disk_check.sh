#!/bin/bash

# This script checks disk space of /dev/sda and alerts when its greater than the threshold that's set (90% default)
# Setting to change in OT-Settings/config.sh:
# SPACE_THRESHOLD: Set this to what percentage it should alert above.
#
# To schedule this job in the servers Cron:
# crontab -e
# Press "1" (if asked) to select nano as the editor
# On a new line paste the following:
# 0 0 * * * /root/OT-NodeWatch/disk_check.sh

source /root/OT-Settings/config.sh

SPACE=$(df -k / | tail -n 1 | awk '{print $5}' | sed 's|%||')

echo "Disk space is $SPACE% full."

if [ $SPACE -ge $DISK_CHECK_THRESHOLD ]; then
  /root/OT-Settings/data/send.sh "Disk space is $SPACE% full."
fi
