# OT-DockSucker

## __Before proceeding, you must complete the OT-Settings repository instructions first__
```
git clone https://github.com/calr0x/OT-Settings.git
```

Convert your OriginTrail Docker node to dockerless.

You need to create a new server using __Ubuntu 18.04__, this will not work on Ubuntu 20.04.

__The following steps assume that you have either :__
1. backed up your old dockerless node using restic from OT-Smoothbrain-Backup or ;
2. restored a backup on /root/backup ready to go dockerless.

__If none of these apply, please consult the next section for instructions__

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

## __How to prepare a backup to use on OT-DockSucker:__

Node runners usually look for dockerless when they run out of space on docker nodes. Therefore, they won't be able to use OriginTrail's backup script to generate a backup since OriginTrail's data and arangodb files need to be duplicated onto the docker's /ot-node/backup folder before being transfered out to Amazon AWS. 

The backup process will then output an error message about failing to upload one of arangodb's files and __BACKUP HAS FAILED !__ will be shown

### __You have 2 options:__
__1. Add a temporary drive__ (instructions below are for Hetzner) 
1. Add a temporary volume and mount it on your current node. The volume should be at least the size of your current disk capacity (Hetzner have this option)__
2. Format the volume using ext4 following Hetzner's script (change 1111111111 to your drive's assigned number):
    - sudo mkfs.ext4 /dev/disk/by-id/scsi-0HC_Volume_1111111111
3. Locate your backup directory using OriginTrail's backup script:
    - df -h
    - notice the var/lib/docker/overlay2/............/merged folder
4. Add /ot-node/backup at the end of the previous path, then run the following command (change 1111111111 and .............):
    - mount -o discard,defaults /dev/disk/by-id/scsi-0HC_Volume_1111111111 /var/lib/docker/overlay2/............./merged/ot-node/backup
5. You have successfully mounted your temporary drive to the docker otnode backup folder, now you can run the backup script:
    - docker exec otnode node scripts/backup.js --config=/ot-node/.origintrail_noderc --configDir=/ot-node/data --backupDirectory=/ot-node/backup
6. Once you are done backing up, unmount the drive:
    - umount /var/lib/docker/overlay2/............./merged/ot-node/backup
    - unmount the volume on Hetzner after this
7. Create a new __Ubuntu 18.04__ server and SSH into the server
8. Mount the previous volume to this server on Hetzner in the volumes section
    - Choose manual mount and DO NOT FORMAT IT ! It has your backup inside !
9. Run the mount command (change 1111111111):
    - mount -o discard,defaults /dev/disk/by-id/scsi-0HC_Volume_1111111111 /root/backup
10. The files in your backup is actually in another folder with a time stamp. You need the backup files to be on /root/backup and not /root/backup/2021-07-... so run following commands :
    - mv -v /root/backup/20*/* /root/backup
    - mv -v /root/backup/20*/.origintrail_noderc /root/backup
    - rm -rf /root/backup/20*
11. You are now ready to run install-from-existing-local-volume.sh ! Go back to the beginning of this tutorial and start from there !

__2. Increase the capacity of your node__

Since you will be nuking your node after the dockerless install, you can just double your current node's storage space, create the backup, then destroy the node once everything is done. For the new server, if you atttempt to restore with the same usual storage capacity as your old node, you might run out of space due to the backup taking up a big chunk of it. That's why I'd suggest VPS providers like Hetzner who allows you to have a removable temporary drive. If you choose another VPS provider, choose one that allows you to downgrade the size of your server, if you don't you will have to upgrade even though dockerless will save you some space. By choosing a provider that allows you do downgrade, once the restore is finished on your new dockerless node, you should have plenty of space to be able to downgrade.

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
