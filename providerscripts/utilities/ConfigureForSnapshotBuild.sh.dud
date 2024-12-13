#!/bin/sh

if ( [ -f ${HOME}/runtime/DATABASE_READY ] && [ -f ${HOME}/runtime/SNAPSHOT_BUILT ] && [ ! -f ${HOME}/runtime/SNAPSHOT_PRIMED ] )
then
        if ( [ -f ${HOME}/runtime/CREDENTIALS_PRIMED ] )
        then
                /bin/rm ${HOME}/runtime/CREDENTIALS_PRIMED
        fi

 	${HOME}/providerscripts/utilities/UpdateInfrastructure.sh

        ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh dbp.dat ${HOME}/runtime/dbp.dat
        db_prefix="`/bin/cat ${HOME}/runtime/dbp.dat`"
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
        then
                command=""

                for table in `${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh 'show tables LIKE "'${db_prefix}'%";' 'raw'`
                do
                        command="${command} drop table ${table};"
                done

                command="${command} drop table zzzz;"
                ${HOME}/providerscripts/utilities/helperscripts/ConnectToLocalMySQL.sh "${command}"
                ${HOME}/applicationdb/InstallApplicationDB.sh
        fi
        /bin/touch ${HOME}/runtime/SNAPSHOT_PRIMED
fi
