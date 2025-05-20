#!/bin/sh
########################################################################################
# Description: This script initialises the Postgres db instance ready for use.
# It can be either a local database or a remote managed database. 
# Once this script has run, an empty database with a known name and user will have been
# created. 
# Author: Peter Winter
# Date: 15/01/2017
########################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
####################################################################################
####################################################################################
set -x

IP_MASK="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"

DB_U="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
    HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'MYIP'`"
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    if ( [ ! -d ${HOME}/runtime/postgres-init ] )
   then
      /bin/mkdir -p ${HOME}/runtime/postgres-init
   fi
   
   /bin/cp ${HOME}/providerscripts/database/selfmanaged/postgres/live/postgres.psql ${HOME}/runtime/postgres-init/initialiseDB.psql
    /bin/sed -i "s/XXXXDB_NXXXX/${DB_N}/g" ${HOME}/runtime/postgres-init/initialiseDB.psql
    /bin/sed -i "s/XXXXDB_UXXXX/${DB_U}/g" ${HOME}/runtime/postgres-init/initialiseDB.psql
    /bin/sed -i "s/XXXXDB_PXXXX/${DB_P}/g" ${HOME}/runtime/postgres-init/initialiseDB.psql
  #  /bin/sed -i "s/XXXXHOSTXXXX/${HOST}/g" ${HOME}/runtime/postgres-init/initialiseDB.psql
    /bin/sed -i "s/XXXXIP_MASKXXXX/${IP_MASK}/g" ${HOME}/runtime/postgres-init/initialiseDB.psql

${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql start

    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 < ${HOME}/runtime/postgres-init/initialiseDB.psql
            
    ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql restart

    postgres_config="`/usr/bin/find / -name pg_hba.conf -print | /usr/bin/tail -1`"
    postgres_pid="`/usr/bin/find / -name postmaster.pid -print | /usr/bin/tail -1`"
    postgres_sql_config="`/usr/bin/find / -name postgresql.conf -print | /bin/grep etc | /usr/bin/tail -1`"

    /bin/rm ${postgres_pid}
    /bin/sed -i "/listen_addresses/c\        listen_addresses = '*'" ${postgres_sql_config}
    /bin/sed -i "/^port/c\        port = ${DB_PORT}" ${postgres_sql_config}
    /bin/sed -i "/^#port/c\        port = ${DB_PORT}" ${postgres_sql_config}

    IP_MASK="`/bin/echo ${IP_MASK} | /bin/sed 's/%/0/g'`"
    
    /bin/sed -i '/127.0.0.1/d' ${postgres_config}
    /bin/sed -i '/128/d' ${postgres_config}
    /bin/echo "host       ${DB_N}              ${DB_U}            ${IP_MASK}/16          md5" >> ${postgres_config}
    /bin/echo "host       all              ${DB_U}            127.0.0.1/32          trust" >> ${postgres_config}
    /bin/echo "host       all              postgres            127.0.0.1/32         trust" >> ${postgres_config}
 
 
 
 
 #   ${HOME}/providerscripts/database/selfmanaged/postgres/InitialiseDatabaseConfig.sh

#elif ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ]  )
#then
#    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d template1 -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';"
#    
#    if ( [ "$?" != "0" ] )
#    then
#        export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d defaultdb -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';"
#    fi
#    
#    if ( [ "$?" != "0" ] )
#    then
#        export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d template1 -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';"
#    fi
#    
#    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} defaultdb -c "CREATE EXTENSION pg_trgm;" 
#    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} template1 -c "CREATE EXTENSION pg_trgm;" 

fi
