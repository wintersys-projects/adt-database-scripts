#!/bin/sh
########################################################################################
# Description: This script will setup the postgres database ready for the application
# to be installed. It will be setup with the postgres user having its password set to
# $DB_P which is available as a config value
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


DB_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

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
   if ( [ ! -d ${HOME}/runtime/postgres-init ] )
   then
      /bin/mkdir -p ${HOME}/runtime/postgres-init
   fi
   
   /bin/cp ${HOME}/providerscripts/database/selfmanaged/postgres/live/postgres.psql ${HOME}/runtime/postgres-init/initialiseDB.psql

    /usr/bin/sudo -u postgres /usr/bin/psql -h 127.0.0.1 -p ${DB_PORT} template1 < ${HOME}/runtime/postgres-init/initialiseDB.psql

    /bin/rm ${postgres_pid}
            
    ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql restart
    
    if ( [ "$?" != "0" ] )
    then
        /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl restart -D /usr/local/pgsql/data/ -l /home/postgres/logfile"   
        if ( [ "$?" = "0" ] )
        then
           /bin/sed -i "s/trust/md5/g" ${postgres_config}
           /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl reload -D /usr/local/pgsql/data/ -l /home/postgres/logfile"   
        fi
    else
       /bin/sed -i "s/trust/md5/g" ${postgres_config}
        ${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh postgresql reload
    fi
fi
