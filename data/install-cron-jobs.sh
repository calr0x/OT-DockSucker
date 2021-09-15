#!/bin/bash


CRONCMD="/root/OT-2Nudes1DockSucker/NodeWatch/bid_check.sh"
CRONJOB="0 * * * * $CRONCMD"

( crontab -l | grep -v -F "$CRONCMD" ; echo "$CRONJOB" ) | crontab -

CRONCMD="/root/OT-2Nudes1DockSucker/NodeWatch/disk_check.sh"
CRONJOB="0 0 * * * $CRONCMD"

( crontab -l | grep -v -F "$CRONCMD" ; echo "$CRONJOB" ) | crontab -