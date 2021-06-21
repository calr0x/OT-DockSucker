#!/bin/bash
echo Running arango password update script...

FOLDERDIR=$1
echo Using ${FOLDERDIR} as node data folder

touch ${FOLDERDIR}/arango.txt
new_arango_password=password
echo Generated new arango password!

echo -n $new_arango_password > ${FOLDERDIR}/arango.txt
echo New arango password stored in ${FOLDERDIR}/arango.txt file

#cat ${FOLDERDIR}/arango.txt
#echo Generated new arango password: $new_arango_password

touch arango-password-script.js

echo 'try {'                                                        > arango-password-script.js
echo '    require("@arangodb/users").replace("root", ARGUMENTS[0]);'>> arango-password-script.js
echo '    print("SUCCESS");'                                        >> arango-password-script.js
echo '} catch (error) {'                                            >> arango-password-script.js
echo '    print("FAILURE");'                                        >> arango-password-script.js
echo '    print(error);'                                            >> arango-password-script.js
echo '}'                                                            >> arango-password-script.js

echo Updating arango server password

systemctl stop arangodb3
sed -i 's/authentication = true/authentication = false/g' /etc/arangodb3/arangod.conf
systemctl start arangodb3
sleep 10s

status=$(/usr/bin/arangosh --server.password "" --javascript.execute arango-password-script.js ${new_arango_password})

systemctl stop arangodb3
sed -i 's/authentication = false/authentication = true/g' /etc/arangodb3/arangod.conf
systemctl start arangodb3
sleep 10

rm arango-password-script.js

if [[ $status != "SUCCESS" ]];
then
    echo "Password update failed"
    echo $status
    mv ${FOLDERDIR}/arango.txt ${FOLDERDIR}/arango_failed.txt
    exit 1
fi

echo ""
echo "==================================================="
echo "====                                           ===="
echo "====   Arango password successfully updated!   ===="
echo "====                                           ===="
echo "==================================================="
