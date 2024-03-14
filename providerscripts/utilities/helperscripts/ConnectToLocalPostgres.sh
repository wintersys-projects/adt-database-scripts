#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: Connect to the remote Postgres database and execute a query if 
# present. It uses the provided credentials that are part of the build process.
# It takes two parameters, the first is any command to execute and the second is whether
# it is to be of raw format or not. 
#####################################################################################
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
#######################################################################################
#######################################################################################
#set -x

SERVER_USER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

sql_command="$1"
raw="$2"

DB_N="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 1" && eval ${command}`"
DB_P="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 2" && eval ${command}`"
DB_U="`command="${SUDO} ${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh credentials/shit 3" && eval ${command}`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "databaseip/*"`"
    HOST2="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "databasepublicip/*"`"
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

export PGPASSWORD=${DB_P}

if ( [ "${raw}" != "raw" ] )
then
    if ( [ "${sql_command}" != "" ]  )
    then
        /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N} -c "${sql_command}"
        if ( [ "$?" != "0" ] )
        then
            /usr/bin/psql -U ${DB_U} -h ${HOST2} -p ${DB_PORT} ${DB_N} -c "${sql_command}"
        fi
    else
        /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N}
        if ( [ "$?" != "0" ] )
        then
            /usr/bin/psql -U ${DB_U} -h ${HOST2} -p ${DB_PORT} ${DB_N}
        fi
    fi
else
    if ( [ "${sql_command}" != "" ]  )
    then
        /usr/bin/psql -t -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N} -c "${sql_command}"
        if ( [ "$?" != "0" ] )
        then
            /usr/bin/psql -t -U ${DB_U} -h ${HOST2} -p ${DB_PORT} ${DB_N} -c "${sql_command}"
        fi
    else
        /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N} 
        if ( [ "$?" != "0" ] )
        then
            /usr/bin/psql -U ${DB_U} -h ${HOST2} -p ${DB_PORT} ${DB_N} 
        fi
    fi
fi
