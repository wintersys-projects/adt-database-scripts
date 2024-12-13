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
#set -x

IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYIP'`"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
then
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
    
    . ${HOME}/providerscripts/database/singledb/postgres/InitialiseDatabaseConfig.sh

elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ]  )
then
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d template1 -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';"
    
    if ( [ "$?" != "0" ] )
    then
        export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d defaultdb -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';"
    fi
    
    if ( [ "$?" != "0" ] )
    then
        export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} -d template1 -c "CREATE DATABASE ${DB_N} ENCODING 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';"
    fi
    
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} defaultdb -c "CREATE EXTENSION pg_trgm;" 
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} template1 -c "CREATE EXTENSION pg_trgm;" 

fi
