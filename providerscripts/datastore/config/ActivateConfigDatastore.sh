/usr/bin/inotifywait -q -m -r -e modify,delete,create /var/lib/adt-config | while read DIRECTORY EVENT FILE 
do
        case $EVENT in
                MODIFY*)
                        file_modified "$DIRECTORY" "$FILE"
                        ${HOME}/providerscripts/datastore/configwrapper/SyncToDatastoreWithoutDelete.sh

                        ${HOME}/providerscripts/datastore/configwrapper/SyncFromDatastoreWithDelete.sh "root" "/var/lib/adt-config" "yes" > ${HOME}/runtime/datastore_workarea/config/updates.log

                        ;;
                CREATE*)
                        file_created "$DIRECTORY" "$FILE"
                        ;;
                DELETE*)
                        file_removed "$DIRECTORY" "$FILE"
                        ;;
        esac
done
