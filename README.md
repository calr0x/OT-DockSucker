# OT-DockSucker
Convert your OriginTrail Docker node to dockerless.

__TENTATIVE INSTRUCTIONS:__ THESE INSTRUCTIONS ARE *VERY* ROUGH AND HAVE NOT BEEN TESTED WELL. DO NOT ATTEMPT THIS UNLESS YOU HAVE POTENTIAL TIME TO BURN.

IT IS RECOMMENDED TO MAKE A BACKUP ON THE NODE YOU ARE ATTEMPTING TO CONVERT TO DOCKERLESS AND THEN SHUT THAT NODE DOWN DURING THIS PROCESS. IF YOU GET A JOB WHILE PERFORMING THESE STEPS THAT JOB WILL NOT BE REFLECTED ON THE NEW DOCKERLESS NODE.

Create a VPS using Ubuntu 18.04. 20.04 will NOT work. Any version other than 18.04 CANNOT be used.

apt update && apt upgrade -y
apt install -y build-essential gcc python-dev git ccze

cd
git clone https://github.com/calr0x/OT-DockSucker.git
cd OT-DockSucker
./install.sh

apt-mark hold arangodb3 nodejs
mkdir /ot-node && mv /root/OT-DockSucker/ot-node/ /ot-node/5.0.4
ln -s /ot-node/5.0.4 /ot-node/current
cd /ot-node/current
echo NODE_ENV=mainnet >> .env
cp /root/OT-DockSucker/update-arango-password.sh /ot-node/current/scripts
./scripts/update-arango-password.sh

cp /root/backup/.origintrail_noderc /ot-node/current/

---------------------------------------------------------------
RESTORE DB BACKUP (Using SmoothBrain)

** If you are NOT using Smoothbrain Backup, the BACKUP files all need to be in /root/backup. Only the various files and arangodb/migrations directories should be in here. THE BELOW DIRECTIONS ARE ONLY FOR SMOOTHBRAIN BACKUP USERS. YOUR STEPS WILL VARY BASED ON YOUR BACKUP METHOD.**

git clone https://github.com/calr0x/OT-Smoothbrain-Backup.git
cd OT-Smoothbrain-Backup
nano config.sh (fill it out)
source config.sh
./restic snapshots -H <PUT_HOSTNAME_HERE>
./restic restore <PUT_SNAPSHOT_ID_HERE> --target /root
mv /root/root/OT-Smoothbrain-Backup/backup/ /root/backup
rm -rf /root/root
nano /root/backup/.origintrail_noderc

**VERIFY THE IP NEEDS TO CHANGE/BE THE SAME**

ctrl+s/ctrl+x
cd /root/OT-DockSucker
./restore
rm -rf /root/backup/arangodb
cp -r /root/backup/* /root/.origintrail_noderc/mainnet/
---------------------------------------------------------------
cd /ot-node/current
nano config/config.json
  Find "mainnet"
  Find "database"
  Find "password"
  Change "root" to "password"
  ctrl+s/ctrl+x
npm run setup
npm start

The node will start. Let it run for 10 minutes and verify it joins the network and does its thing. Once you have confirmed its working:
ctrl+x
cp /root/OT-DockSucker/otnode.service /lib/systed/system
systemctl enable otnode.service
systemctl start otnode
journalctl -u otnode | ccze -A
The above command is the equivalent to "docker logs -f otnode". The ccze app add colors.
