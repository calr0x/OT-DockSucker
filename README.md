# OT-DockSucker
Convert your OriginTrail Docker node to dockerless.

These steps assume that you have backed up your old node using restic from OT-Smoothbrain-Backup. Please follow the instructions over there first if you haven't yet. 

You need to create a new server using __Ubuntu 18.04__, this will not work on Ubuntu 20.04.

__Before proceeding, you must complete the OT-Settings repository instructions first__

```
cd
```

__Set HOSTNAME to the same hostname as the original docker server was. This is needed for Smoothbrain to identify the correct backup to restore.__
```
hostnamectl set-hostname HOSTNAME
```

__Update and git clone__
```
apt update && apt upgrade -y && apt install git -y
```
```
git clone https://github.com/calr0x/OT-DockSucker.git && git clone https://github.com/calr0x/OT-Settings.git
```
```
cp OT-Settings/config-example.sh OT-Settings/config.sh && nano OT-Settings/config.sh
```
```
cd OT-DockSucker
```
__Install (might take a while)__
```
./install-from-existing.sh
```

__Install is done!__

\
\
__EXTRAS__
\
\
__Set maximum journal space to 50MB__
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
