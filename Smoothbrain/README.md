# __OT-Smoothbrain-Backup__

__Only works on dockerless nodes__

__Do not use this repository to try and backup your docker node to restore on dockerless with OT-DockSucker, use other methods on otnode.com to backup and restore first__

Automated and self sustaining backup system for OriginTrail Nodes using restic snapshots 

## __Key advantages of OT-Smoothbrain-Backup:__  

1. This backup process updates what is _new_ or _changed_. Files that haven't changed do not need to be reuploaded. This is called "de-duplication" in the backup world. This means it takes up significantly less space _and_ there is no penalty for frequent backup. OriginTrail's current backup system copies 100% of everything it is backing up and sends it to Amazon every time. This means if your backup size is 10gig and you run it once a day you will have 70gig in a week. It also doesn't address verification nor does it ever delete old backups off of Amazon on a regular schedule. 

2. This brings us to our second point - frequent backups need to be occurring. If you backup your node twice a week on Mondays and on Fridays and your server dies in such a way that your data isn't recoverable, you lose _all_ the jobs you won since your last backup. Today that might not amount to much but tomorrow it _will_. A job is a job and there is no reason to lose a job plus your collateral over data loss. This system, by default, backs up four times a day (12pm/6pm/12am/6am localtime) and is user-changeable. There is no limit to the amount of times you want to run the backup, and frequent backups will not result in creased backup storage space.

3. On a daily basis, a cleanup script will automatically prune all backups and only keep the latest snapshot of the most recent backup. A snapshot is a backup of the new or changed files since the _previous_ snapshot/backup. In this process it merges the data from those previous backups so this remaining snapshot contains a full image of the current state of the files. 

4. The cleanup script also checks the files in the snapshots for consistency and accuracy and report on Telegram notifications.

Hence, OT-Smoothbrain-Backup is a significantly improved version of the standard backup method provided by the team... :)

## __Prerequisites:__ 

1. OT-Settings repository
2. Amazon AWS account - please refer to OT-Settings repository for instructions on how to set up a bucket. 
3. Telegram bot - please refer to OT-Settings repository for instructions
4. Linux OS - can use the same as one of your nodes, or the same as your Ansible control computer (see OT-Ansible-Files-and-Playbooks repository for instructions if you are going the Ansible way)
5. If you use a __Raspberry Pi__ as your Linux OS, you need to download a different restic binary from the restic website :
```
wget https://github.com/restic/restic/releases/download/v0.12.0/restic_0.12.0_linux_arm.bz2
```
```
bunzip2 restic_0.12.0_linux_arm.bz2
```
```
cp restic_0.12.0_linux_arm restic
```
```
chmod +x restic
```
## __BACKUP INSTRUCTIONS:__

The following section will help automate restic backups of your current __dockerless__ node

### __Initial setup:__

First, log in as root
```
cd
```
```
git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git
```
```
git clone https://github.com/calr0x/OT-Settings.git
```
__Follow OT-Settings repository instructions to complete that section FIRST before proceeding__
```
source /root/OT-Settings/config.sh
```
```
cd OT-Smoothbrain-Backup
```
```
./restic init
```
### __Configure crontab:__

The below command will automate a restic backup every 6 hours starting from midnight. You can change the frequency if you want, and to guide you, consult : https://crontab.guru/
```
(crontab -l 2>/dev/null; echo "0 */6 * * * /root/OT-Smoothbrain-Backup/restic-backup.sh") | crontab -
```
The below command will automate a restic cleanup (prune) every day at 3am. You can change the frequency if you want. 
```
(crontab -l 2>/dev/null; echo "0 3 * * * /root/OT-Smoothbrain-Backup/restic-cleanup.sh") | crontab -
```

### __To run a backup immediately:__
```
./restic-backup.sh
```

### __Backup cleanup:__

The following command will schedule a daily cleanup of the restic repository to clear old backup snapshots. It is __not__ to be run on every server. It must be installed on only one server and can be a node or a Linux server that's not a node.
```
(crontab -l 2>/dev/null; echo "0 3 * * * /root/OT-Smoothbrain-Backup/restic-cleanup.sh") | crontab -
```
\
If you even encounter an error stating there's a restic lock, run
```
source /root/OT-Settings/config.sh
```
```
./root/OT-Smoothbrain-Backup/restic unlock
```
\
Automated SmoothBrain backup done!

For restore instructions, follow OT-DockSucker repository instructions !
