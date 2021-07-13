#!/bin/bash

BACKUPDIR="/root/backup"
CONFIGDIR="/root/.origintrail_noderc/mainnet"

temp_folder=$BACKUPDIR

for file in `ls ${BACKUPDIR}`; do
    if [ ! ${file}] == "arangodb" ]
    then
      sourcePath="${BACKUPDIR}/${file}"
      destinationPath="${CONFIGDIR}/"

      sourcePath=${temp_folder}/${file}
      echo "cp ${sourcePath} ${destinationPath}"
      cp ${sourcePath} ${destinationPath}
    fi
done

sourcePath=${BACKUPDIR}/.origintrail_noderc
destinationPath="/ot-node/current/"

echo "cp ${sourcePath} ${destinationPath}"
cp ${sourcePath} ${destinationPath}

migrationDir="${BACKUPDIR}/migrations"
if [ -d ${migrationDir} ]
then
  sourcePath=${BACKUPDIR}/migrations
  destinationPath="${CONFIGDIR}/"

  echo "cp ${sourcePath} ${destinationPath}"
  cp -r ${sourcePath} ${destinationPath}
fi

databasePassword=$(cat /root/.origintrail_noderc/mainnet/arango.txt)

echo "arangorestore --server.database origintrail --server.username root --server.password "root" --input-directory backup/arangodb/ --overwrite true --create-database true"
arangorestore --server.database origintrail --server.username root --server.password "${databasePassword}" --input-directory /root/backup/arangodb/ --overwrite true --create-database true
