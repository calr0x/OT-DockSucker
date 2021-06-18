#!/bin/bash
function printUsage {
        echo ""
        echo "Usage:"
        echo "    restore.sh [--backupDir=<backup_directory_path>] [--configDir=<config_directory_path>]"
        echo "Options:"
        echo "    --backupDir=<backup_directory_path>\
        Specify the path to the folder containing the backup data on your device. Defaults to the folder with the most recent timestamp inside the backu$
        echo "    --backupDir=<config_directory_path>
        Specify the path to the folder inside the container where configuration files are stored. Defaults to /ot-node/data/"
        echo ""
}

BACKUPDIR="/root/backup"
CONFIGDIR="/root/.origintrail_noderc/mainnet"
CONTAINER_NAME="otnode"

if [ -d ${BACKUPDIR} ]
then
        echo "Using ${BACKUPDIR} as the backup directory"
        echo ""
else
        echo "Given backup directory parameter ${BACKUPDIR} is not a directory!"
        printUsage
        exit 1
fi

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

#databaseName=$(cat ${BACKUPDIR}/arangodb/database.txt)
#echo "database name ${databaseName}"

#databaseUsername=$(cat ${BACKUPDIR}/arangodb/username.txt)
#echo "database username ${databaseUsername}"

#cp ${CONFIGDIR}/arango.txt arango.txt
#databasePassword=$(cat arango.txt)

echo "arangorestore --server.database origintrail --server.username root --server.password "password" --input-directory backup/arangodb/ --overwrite true --create-database true"
arangorestore --server.database origintrail --server.username root --server.password "password" --input-directory /root/backup/arangodb/ --overwrite true --create-database true
