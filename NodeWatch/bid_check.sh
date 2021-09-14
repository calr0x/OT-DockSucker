#!/bin/bash

# This script checks the logs for "Accepting" which indicates a bid.
# Setting to change in OT-Settings/config.sh:
# BID_CHECK_JOB_NOTIFY_ENABLED: Set to false to disable bid notifications (default true)
# BID_CHECK_INTERVAL: Set this to how far back to search the log for mentions of "Accepting" (default 1 hour).
#
# This value should match the CRON schedule. For example, Every 1 hour
# CRON should run this script which checks the logs for the past 1 hour.
#
# This script requires the following app to be installed:
# apt install jq
#
# To schedule this job in the servers Cron:
# crontab -e
# Press "1" (if asked) to select nano as the editor
# On a new line paste the following:
# 0 * * * * /root/OT-NodeWatch/bid_check.sh

source /root/OT-Settings/config.sh

BIDS=$(journalctl -u otnode.service --since "$BID_CHECK_INTERVAL" | grep Accepting | wc -l)
JOBS=$(curl -sX GET "https://v5api.othub.info/api/jobs/jobcreatedcountinperiod?timePeriod=hours&time=1&blockchainID=2")
#echo Bids: $BIDS

if [ $BIDS -eq 0 ]; then
  if [ $JOBS -ne 0 ]; then
    /root/OT-Settings/data/send.sh "Has not bid since $BID_CHECK_INTERVAL and jobs are being issued, restarting node"
    systemctl restart otnode
  fi
fi

OFFER_ID=($(journalctl -u otnode.service --since "$BID_CHECK_INTERVAL" | grep 've been chosen' | grep -Eo '0x[a-z0-9]+'))

#echo Array: ${#OFFER_ID[@]}
if [ $BID_CHECK_JOB_NOTIFY_ENABLED == "true" ]
then
  for i in "${OFFER_ID[@]}"
  do
    TOKEN_ARRAY=($(curl -sX GET "https://v5api.othub.info/api/Job/detail/$i" -H  "accept: text/plain" | jq '.TokenAmountPerHolder' | cut -d'"' -f2))
    JOBTIME_ARRAY=($(curl -sX GET "https://v5api.othub.info/api/Job/detail/$i" -H  "accept: text/plain" | jq '.HoldingTimeInMinutes'))
    DAYS=$(expr ${JOBTIME_ARRAY[@]} / 60 / 24)
    /root/OT-Settings/data/send.sh "Job awarded: $DAYS days at ${TOKEN_ARRAY[@]} TRAC"
  done
fi
