#!/bin/sh
########################################################################################
# Description: This script will setup the postgres database ready for the application
# to be installed. It will be setup with the postgres user having its password set to
# $DB_P which is available in ${HOME}/credentials/shit
#
# Author: Peter Winter
# Date: 17/06/2021
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

#if ( [ -f ${HOME}/runtime/POSTGRES_CONFIGURED ] )
#then
#    exit
#fi

DB_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

#DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
#DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
#DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

#DB_N="`/bin/sed '1q;d' ${HOME}/credentials/db_cred`"
#DB_P="`/bin/sed '2q;d' ${HOME}/credentials/db_cred`"
#DB_U="`/bin/sed '3q;d' ${HOME}/credentials/db_cred`"

DB_U="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

postgres_config="`/usr/bin/find / -name pg_hba.conf -print | /usr/bin/tail -1`"

running="0"
   
${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql restart

if ( [ "$?" != "0" ] )
then
    /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl restart -D /usr/local/pgsql/data/ -l /home/postgres/logfile"
    if ( [ "$?" = "0" ] )
    then
        running="1"
    else
        running="1"
    fi
else
    running="1"
fi

if ( [ "${running}" = "1" ] )
then
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE USER ${DB_U} WITH ENCRYPTED PASSWORD '${DB_P}';"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "ALTER USER ${DB_U} WITH SUPERUSER;"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;"
    if ( [ "$?" != "0" ] )
    then   
        /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8' TEMPLATE template0;"
    fi

    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_N} to ${DB_U};"
    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 -c "ALTER USER postgres PASSWORD '${DB_P}';"
    
    export PGPASSWORD="${DB_P}" && /usr/bin/psql -h 127.0.0.1 -U ${DB_U} -p ${DB_PORT} ${DB_N} -c "CREATE EXTENSION pg_trgm;" 

    /bin/rm ${postgres_pid}
            
    ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql restart
    
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl restart -D /usr/local/pgsql/data/ -l /home/postgres/logfile"   
        if ( [ "$?" = "0" ] )
        then
 #          /bin/touch ${HOME}/runtime/POSTGRES_CONFIGURED
           /bin/sed -i "s/trust/md5/g" ${postgres_config}
           /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl reload -D /usr/local/pgsql/data/ -l /home/postgres/logfile"   
        fi
    else
       /bin/sed -i "s/trust/md5/g" ${postgres_config}
        ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql reload
    fi
fi
