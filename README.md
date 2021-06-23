# OT-DockSucker
Convert your OriginTrail Docker node to dockerless.

```
cd
```
__Set HOSTNAME to the same hostname as the original docker server was. This is needed for Smoothbrain to identify the correct backup to restore.__
```
hostnamectl set-hostname HOSTNAME
```
```
apt update && apt upgrade -y && apt install git -y
```
```
git clone https://github.com/calr0x/OT-DockSucker.git
```
```
cd OT-DockSucker
```

__Edit the Smoothbrain config and paste in your correct values:__
```
nano data/config.sh
```
```
ctrl+s ctrl+x
```
```
./install-docksucker.sh
```

__Install is done!__

To do:  
copy:  
bid_check.sh  
restic-backup.sh  
