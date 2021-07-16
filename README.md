# OT-DockSucker
Convert your OriginTrail Docker node to dockerless.

You need to create a new server using __Ubuntu 18.04__, this will not work on Ubuntu 20.04.

__These steps assume that you have backed up your old node using restic from OT-Smoothbrain-Backup or have a restored backup ready on the new node's /root/backup folder.__

__Before proceeding, you must also complete the OT-Settings repository instructions first__

```
cd
```

__Set HOSTNAME to the same hostname as the original docker server was. This is needed for Smoothbrain to identify the correct restic backup to restore. (ignore this step if you are not using restic to restore)__
```
hostnamectl set-hostname HOSTNAME
```

__Update and clone repository__
```
apt update && apt upgrade -y && apt install git -y
```
```
git clone https://github.com/calr0x/OT-DockSucker.git
```
```
cd OT-DockSucker
```
__Install (might take a while)__

If your backup comes from a restic snapshot from OT-Smoothbrain-Backup, run:
```
./install-from-existing.sh
```
If you have a backup restored on /root/backup on your new server, run:
```
./install-from-existing-local-volume.sh
```

__Install is done!__

\
\
__EXTRAS__
\
\
__Set maximum journal space to 50MB__ (This command is included in all DockSucker installers)
```
sed -i 's|#SystemMaxUse=|SystemMaxUse=50M|' /etc/systemd/journald.conf
```
```
systemctl restart systemd-journald
```
\
__Remove old crontab inputs and set the crontab for the new dockerless bid check__
```
crontab -r
```
```
{ crontab -l; echo "0 * * * * /root/OT-NodeWatch/bid_check/bid_check-dockerless.sh"; } | crontab -
```
```
{ crontab -l; echo "0 */6 * * * /root/OT-Smoothbrain-Backup/restic-backup.sh"; } | crontab -
```
```
{ crontab -l; echo "0 0 * * * /root/OT-NodeWatch/disk_check/disk_check.sh"; } | crontab -
```
\
\
__Useful commands__
```
systemctl start otnode
```
```
systemctl stop otnode
```
```
systemctl restart otnode
```
```
journalctl -u otnode -f | ccze -A
```
```
journalctl -u otnode -f --since "1 hour ago"
```
```
journalctl -u otnode -f --since "24 hours ago" |egrep 'cheap'\|'Accepting'\|'ve been chosen'
```
```
journalctl -u arangodb3 -f
```
