# OT-DockSucker
Convert your OriginTrail Docker node to dockerless.

__TENTATIVE INSTRUCTIONS:__ THESE INSTRUCTIONS ARE *VERY* ROUGH AND HAVE NOT BEEN TESTED WELL. DO NOT ATTEMPT THIS UNLESS YOU HAVE POTENTIAL TIME TO BURN.

IT IS RECOMMENDED TO MAKE A BACKUP ON THE NODE YOU ARE ATTEMPTING TO CONVERT TO DOCKERLESS AND THEN SHUT THAT NODE DOWN DURING THIS PROCESS. IF YOU GET A JOB WHILE PERFORMING THESE STEPS THAT JOB WILL NOT BE REFLECTED ON THE NEW DOCKERLESS NODE.

Create a VPS using Ubuntu __18.04__. 20.04 will __NOT__ work. Any version other than 18.04 CANNOT be used.

Login as root
```
cd
```
```
apt update && apt upgrade -y && apt install -y build-essential gcc python-dev git ccze  
```
```
git clone https://github.com/calr0x/OT-DockSucker.git && cd OT-DockSucker  
```
```
./install.sh  
```
```
apt-mark hold arangodb3 nodejs  
```
```
mkdir -p /ot-node && mv /root/OT-DockSucker/ot-node/ /ot-node/5.0.4  
```
```
ln -s /ot-node/5.0.4 /ot-node/current && cd /ot-node/current  
```
```
echo NODE_ENV=mainnet >> .env  
```

---------------------------------------------------------------
__Download Backup (Using SmoothBrain)__

If you are *NOT* using Smoothbrain Backup, the BACKUP files all need to be in /root/backup. Only the various files and arangodb/migrations directories should be in here. *THE BELOW DIRECTIONS ARE ONLY FOR SMOOTHBRAIN BACKUP USERS. YOUR STEPS WILL VARY BASED ON YOUR BACKUP METHOD.*
```
source /root/Smoothbrain-Backup/config.sh && ./restic snapshots -H <PUT_HOSTNAME_HERE>  
```
```
./restic restore <PUT_SNAPSHOT_ID_HERE> --target /root  
```
```
mv /root/root/OT-Smoothbrain-Backup/backup/ /root/backup && rm -rf /root/root  
```

---------------------------------------------------------------
__Edit origintrail_noderc__
```
sed -i -E 's|"hostname": "[[:digit:]]+.[[:digit:]]+.[[:digit:]]+.[[:digit:]]+",|"hostname": '"$ADDRESS"'|g' /root/backup/.origintrail_noderc  
```
```
cp /root/backup/.origintrail_noderc /ot-node/current/  
```

---------------------------------------------------------------  
__Setup and intialize origintrail_noderc__
```
cd /ot-node/current  
```
```
npm run setup  
```
```
./scripts/update-arango-password.sh /root/.origintrail_noderc/mainnet/
```

---------------------------------------------------------------
__Restore node database from backup__
```
cd /root/OT-DockSucker  
```
```
./restore.sh  
```
```
rm -rf /root/backup/arangodb  
```
```
cp -r /root/backup/* /root/.origintrail_noderc/mainnet/  
```

---------------------------------------------------------------  
__Create systemd service and start node__
```
cp /root/OT-DockSucker/otnode.service /lib/systemd/system  
```
```
systemctl enable otnode.service  
```
```
systemctl start otnode  
```
---------------------------------------------------------------  
__Command reference__
docker logs -f otnode is now:
```
journalctl -u otnode | ccze -A  
```

docker stop/start/restart otnode is now:
```
systemctl stop/start/restart otnode
```
