#!/bin/bash
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
sudo apt update && sudo apt-get install -y nodejs libpq-dev sqlite3 python3-pip git build-essential gcc python-dev libpq-dev

db=arangodb

for i in "$@"
do
case $i in
    --db=*|--database=*)
    db="${i#*=}"
    shift # past argument=value
    ;;
esac
done

if [ -z "$db" ]; then
  echo "Parameter expected."
  exit 1
fi

if [ $db != "arangodb" ] && [ $db != "neo4j" ] ; then
    echo "Invalid database: arangodb or neo4j expected."
    exit 1
fi

if [ $db = "arangodb" ]; then
    curl -OL https://download.arangodb.com/arangodb35/DEBIAN/Release.key
    apt-key add - < Release.key
    echo 'deb https://download.arangodb.com/arangodb35/DEBIAN/ /' | tee /etc/apt/sources.list.d/arangodb.list
    apt-get install apt-transport-https -y
    apt-get update -y
    echo arangodb3 arangodb3/password password root | debconf-set-selections
    echo arangodb3 arangodb3/password_again password root | debconf-set-selections
    echo arangodb3 arangodb3/upgrade boolean false | debconf-set-selections
    echo arangodb3 arangodb3/storage_engine select auto | debconf-set-selections
    apt-get install arangodb3=3.5.3-1 -y --allow-unauthenticated
    sed -i 's/authentication = true/authentication = false/g' /etc/arangodb3/arangod.conf
fi

if [ $db = "neo4j" ]; then
  sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
  sudo echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
  sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
  sudo apt-get update -y
  sudo apt-get install -y oracle-java8-installer
  sudo apt-get install -y oracle-java8-set-default

  wget --no-check-certificate -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
  sudo echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
  sudo apt update -y
  sudo apt install neo4j
fi

export LC_ALL=C

sudo pip3 install python-arango
sudo pip3 install xmljson
sudo pip3 install python-dotenv

git clone -b release/mainnet https://github.com/OriginTrail/ot-node.git
cd ot-node && npm install

echo "Node installation complete."
