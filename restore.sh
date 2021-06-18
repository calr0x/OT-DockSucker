#!/bin/bash
function printUsage {
	echo ""
	echo "Usage:"
	echo "    restore.sh [--backupDir=<backup_directory_path>] [--configDir=<config_directory_path>]"
	echo "Options:"
	echo "    --backupDir=<backup_directory_path>\
	Specify the path to the folder containing the backup data on your device. Defaults to the folder with the most recent timestamp inside the backup/ directory"
	echo "    --backupDir=<config_directory_path>
	Specify the path to the folder inside the container where configuration files are stored. Defaults to /ot-node/data/"
	echo ""
}

BACKUPDIR="backup"
CONFIGDIR="none"
CONTAINER_NAME="otnode"

for i in "$@"
do
case $i in
    -h|--help=*)
	printUsage
	exit 0
	# past argument=value
    ;;
    --configDir=*)
    CONFIGDIR="${i#*=}"
    shift # past argument=value
    ;;
    --backupDir=*)
    BACKUPDIR="${i#*=}"
    shift # past argument with no value
    ;;
    --containerName=*)
    CONTAINER_NAME="${i#*=}"
    shift # past argument with no value
    ;;
    *)
     echo "Unknown option detected ${i}"
     printUsage
     exit 2
    ;;
esac
done


# Load backup directory path
if [ ${BACKUPDIR} == "none" ]
then
	echo "No backup directory specified, loading last backup from ./backup folder"
	echo ""
	# Find the latest backup file
	dateExpression=[1-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T
	allBackups=($(ls -dr backup/* | grep "$backup/$dateExpression"))
	latestBackupDir=${allBackups[@]:0:1}
	BACKUPDIR=${latestBackupDir}
fi
if [ -d ${BACKUPDIR} ]
then
	echo "Using ${BACKUPDIR} as the backup directory"
	echo ""
else
	echo "Given backup directory parameter ${BACKUPDIR} is not a directory!"
	printUsage
	exit 1
fi

# Load config directory path
if [ ${CONFIGDIR} == "none" ]
then
	echo "No config directory specified, using /ot-node/data as default"
	echo ""
	CONFIGDIR="/ot-node/data"
else
	echo "Using ${CONFIGDIR} as the data directory"
	echo ""
fi

temp_folder=$BACKUPDIR

for file in `ls ${BACKUPDIR}`; do
    if [ ! ${file}] == "arangodb" ]
    then
      sourcePath="${BACKUPDIR}/${file}"
      destinationPath="${CONFIGDIR}/"

      sourcePath=./${temp_folder}/${file}
      echo "cp ${sourcePath} ${destinationPath}"
      cp ${sourcePath} ${destinationPath}
    fi
done

sourcePath="${BACKUPDIR}/.origintrail_noderc"
destinationPath="/ot-node/current/"

sourcePath=./${temp_folder}/.origintrail_noderc

echo "cp ${sourcePath} ${destinationPath}"
cp ${sourcePath} ${destinationPath}

identitiesDir="${BACKUPDIR}/identities"
if [ -d ${identitiesDir} ]
then
  sourcePath="${BACKUPDIR}/identities"
  destinationPath="${CONFIGDIR}/"

  sourcePath=./${temp_folder}/identities
  echo "cp ${sourcePath} ${destinationPath}"
  cp ${sourcePath} ${destinationPath}
fi

certFiles=(fullchain.pub privkey.pem)
if [ -e "${BACKUPDIR}/fullchain.pem" ] && [ -e "${BACKUPDIR}/privkey.pem" ]
then
	echo "mkdir ${temp_folder}/certs"
	mkdir ${temp_folder}/certs

	echo "cp ${BACKUPDIR}/fullchain.pem ./${temp_folder}/certs/"
	cp ${BACKUPDIR}/fullchain.pem ./${temp_folder}/certs

	echo "cp ${BACKUPDIR}/privkey.pem ./${temp_folder}/certs/"
	cp ${BACKUPDIR}/privkey.pem ./${temp_folder}/certs

	echo "cp ${temp_folder}/certs /ot-node/"
	cp ${temp_folder}/certs otnode:/ot-node/
else
	echo "Cert files do not exits, skipping..."
fi

migrationDir="${BACKUPDIR}/migrations"
if [ -d ${migrationDir} ]
then
  sourcePath="${BACKUPDIR}/migrations"
  destinationPath="${CONFIGDIR}/"

  sourcePath=./${temp_folder}/migrations
  echo "cp ${sourcePath} ${destinationPath}"
  cp ${sourcePath} ${destinationPath}
fi

echo cp /ot-node/current/config/config.json ./
cp /ot-node/current/config/config.json ./

databaseName=$(cat ${BACKUPDIR}/arangodb/database.txt)
echo "database name ${databaseName}"

databaseUsername=$(cat ${BACKUPDIR}/arangodb/username.txt)
echo "database username ${databaseUsername}"

echo "cp ${temp_folder}/arangodb ${CONFIGDIR}/"
cp "${temp_folder}/arangodb" ${CONFIGDIR}/

cp ${CONFIGDIR}/arango.txt arango.txt
databasePassword=$(cat arango.txt)

echo "exec arangorestore --server.database ${databaseName} --server.username ${databaseUsername} --server.password \"${databasePassword}\" --input-directory ${CONFIGDIR}/arangodb/ --overwrite true --create-database true"
arangorestore --server.database origintrail --server.username root --server.password "password" --input-directory backup/arangodb/ --overwrite true --create-database true
