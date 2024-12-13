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
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
        command=""

        for table in `${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh 'show tables LIKE "'${db_prefix}'%";' 'raw'`
        do
                command="${command} drop table ${table};"
        done
        command="${command} drop table zzzz;"
        ${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh "${command}"
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "APPLICATION_INSTALLED"
        ${HOME}/applicationdb/InstallApplicationDB.sh
fi

${HOME}/providerscripts/utilities/UpdateSoftware.sh "SNAPPED"

/bin/touch ${HOME}/runtime/DATABASE_UPDATED_FOR_SNAPSHOT
/bin/rm ${HOME}/runtime/DATABASE_APPLICATION_UPDATING

