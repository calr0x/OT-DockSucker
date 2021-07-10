# OT-DockSucker
Convert your OriginTrail Docker node to dockerless.

These steps assume that you have backed up your old node using restic from OT-Smoothbrain-Backup. Please follow the instructions over there first if you haven't yet. 

You need to create a new server using __Ubuntu 18.04__, this will not work on Ubuntu 20.04.

```
cd
```
\
__Set HOSTNAME to the same hostname as the original docker server was. This is needed for Smoothbrain to identify the correct backup to restore.__
```
hostnamectl set-hostname HOSTNAME
```
\
__Add 1GB swap space to your server (for 2GB RAM servers)__
```
fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && cp /etc/fstab /etc/fstab.bak && echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```
\
__Update and git clone__
```
apt update && apt upgrade -y && apt install git -y
```
```
git clone https://github.com/calr0x/OT-DockSucker.git
```
```
cd OT-DockSucker
```
\
__Edit the Smoothbrain config and paste in your correct values:__
```
nano data/config.sh
```
when you're done, ctrl+s and ctrl+x
\
\
__Install (might take a while)__
```
./install-docksucker.sh
```
```
systemctl start otnode
```
```
journalctl -u otnode -f | ccze -A
```
\
__Install is done!__

\
\
__EXTRAS__
\
\
__Set maximum journal space to 150MB__
```
sed -i 's|#SystemMaxUse=|SystemMaxUse=150M|' /etc/systemd/journald.conf
```
```
systemctl restart systemd-journald
```
\
__If you want to keep using OT-Smoothbrain-Backup for your new DockSucker, you need to copy the dockerless versions of the backup and restore scripts :__
```
cp /root/OT-DockSucker/data/restic-backup.sh /root/OT-Smoothbrain-Backup/restic-backup.sh
```
```
cp /root/OT-DockSucker/data/restore.sh /root/OT-Smoothbrain-Backup/restore.sh
```
\
__Set up OT-NodeWatch to work with DockSucker__
```
cd
```
```
git clone https://github.com/calr0x/OT-NodeWatch.git 
```
```
cd OT-NodeWatch
```
```
nano config.sh
```
enter correct values, when you're done ctrl+s and ctrl+x
\
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
