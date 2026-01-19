#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/06/2021
# Description: Connect to the remote MySQL or MariaDB database and execute a query if 
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

if ( [ -f /usr/bin/mariadb ] )
then
	mysql="/usr/bin/mariadb"
else
	mysql="/usr/bin/mysql"
fi

sql_command="$1"
raw="$2"  
override_db="$3"

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`/bin/echo ${sql_command} | /bin/grep -i 'CREATE DATABASE'`" != "" ] )
then
	DB_N=""
fi

if ( [ "${sql_command}" = "dbaas-init" ] )
then
	if ( [ "${override_db}" != "" ] )
	then
		DB_N="${override_db}"
	else
		DB_N=""
	fi
	sql_command=""
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "databaseip/*"`"
	HOST2="`${HOME}/providerscripts/datastore/config/toolkit/ListFromConfigDatastore.sh "databasepublicip/*"`"
fi

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "${raw}" != "raw" ] )
then
	if ( [ "${sql_command}" != "" ]  )
	then
		${mysql} -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "${sql_command}"
		if ( [ "$?" != "0" ] )
		then
			${mysql} -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST2}" --port="${DB_PORT}" -e "${sql_command}"
		fi
	else
		${mysql} -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}"
		if ( [ "$?" != "0" ] )
		then
			${mysql} -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST2}" --port="${DB_PORT}"
		fi
	fi
else
	if ( [ "${sql_command}" != "" ]  )
	then
		${mysql} -N -r -s -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "${sql_command}"
		if ( [ "$?" != "0" ] )
		then
			${mysql} -N -r -s -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST2}" --port="${DB_PORT}" -e "${sql_command}"
		fi
	else
		${mysql} -N -r -s -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}"
		if ( [ "$?" != "0" ] )
		then
			${mysql} -N -r -s -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST2}" --port="${DB_PORT}"
		fi
	fi
fi
