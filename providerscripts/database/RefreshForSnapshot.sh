#set -x

if ( [ -f ${HOME}/runtime/DATABASE_APPLICATION_UPDATING ] )
then
        exit
fi

if ( [ -f ${HOME}/runtime/SNAPSHOT_BUILT ] )
then
        if ( [ "`/usr/bin/find ${HOME}/runtime/SNAPSHOT_BUILT -maxdepth 1 -mmin -10 -type f`" != "" ] )
        then
                exit
        fi
fi

if ( [ ! -f ${HOME}/runtime/SNAPSHOT_BUILT ] || [ -f ${HOME}/runtime/DATABASE_UPDATED_FOR_SNAPSHOT ] )
then
        exit
fi

/bin/touch ${HOME}/runtime/DATABASE_APPLICATION_UPDATING
        
if ( [ -f ${HOME}/runtime/CREDENTIALS_PRIMED ] )
then
        /bin/rm ${HOME}/runtime/CREDENTIALS_PRIMED
fi

${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh dbp.dat ${HOME}/runtime/dbp.dat
db_prefix="`/bin/cat ${HOME}/runtime/dbp.dat`"
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
        command=""

        for table in `${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh 'show tables LIKE "'${db_prefix}'%";' 'raw'`
        do
                command="${command} drop table ${table};"
        done
        command="${command} drop table zzzz;"
        ${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh "${command}"
        if ( [ -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] )
        then
                /bin/rm ${HOME}/runtime/DB_APPLICATION_INSTALLED
        fi
        ${HOME}/applicationdb/InstallApplicationDB.sh
fi

${HOME}/providerscripts/utilities/software/UpdateSoftware.sh "SNAPPED"

/bin/touch ${HOME}/runtime/DATABASE_UPDATED_FOR_SNAPSHOT
/bin/rm ${HOME}/runtime/DATABASE_APPLICATION_UPDATING

