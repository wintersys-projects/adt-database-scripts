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

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"

SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

sql_command="${1}"
raw="${2}"
override_db="${3}"

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`/bin/echo ${sql_command} | /bin/grep -i 'CREATE DATABASE'`" != "" ] || [ "`/bin/echo ${sql_command} | /bin/grep -i 'DROP DATABASE'`" != "" ] )
then
	DB_N="template1"
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "databaseip/*"`"
	HOST2="`${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "databasepublicip/*"`"
fi

if ( [ "${HOST}" = "" ] && [ "${HOST2}" = "" ] )
then
	HOST="127.0.0.1"
fi

if ( [ "${sql_command}" = "dbaas-init" ] )
then
	if ( [ "${override_db}" != "" ] )
	then
		DB_N="${override_db}"
	fi

	sql_command=""
	if ( [ "`/bin/echo ${DB_U} | /bin/grep ':::'`" != "" ] )
	then
		DB_U="`/bin/echo ${DB_U} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $1}'`"
	fi
	if ( [ "`/bin/echo ${DB_P} | /bin/grep ':::'`" != "" ] )
	then
		DB_P="`/bin/echo ${DB_P} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $1}'`"
	fi
fi

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
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
