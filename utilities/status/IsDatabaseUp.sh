#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 10/4/2016
# Description : Check if the database is up and running
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ -f /usr/bin/mariadb ] )
then
	mysql="/usr/bin/mariadb"
else
	mysql="/usr/bin/mysql"
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/utilities/processing/GetIP.sh`"
fi

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "${HOST}" = "" ] || [ "${DB_PORT}" = "" ] || [ "${DB_N}" = "" ] || [ "${DB_P}" = "" ] || [ "${DB_U}" = "" ] )
then
	exit
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
	${mysql} -A -u ${DB_U} -p${DB_P}  ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'exit'
	if ( [ "$?" = "0" ] )
	then
		/bin/echo "ALIVE"
	else
		/bin/echo "DEAD"
		/bin/echo "${0} `/bin/date`: The Mariadb database has been offline, I am atempting to restart it" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
		${HOME}/providerscripts/email/SendEmail.sh "DATABASE HAS BEEN OFFLINE" "THe Mariadb database has been offline" "ERROR"
		${HOME}/utilities/processing/RunServiceCommand.sh mariadb restart

		if ( [ "$?" != "0" ] )
		then
			/bin/touch ${HOME}/runtime/DATABASE_NOT_RUNNING
			/bin/echo "${0} `/bin/date`: Couldn't restart the mariadb database this is a problem that needs to be looked into" 
			${HOME}/providerscripts/email/SendEmail.sh "DATABASE MIGHT NOT BE RUNNING" "I think that your database might not be running" "ERROR"
		else
			/bin/rm ${HOME}/runtime/DATABASE_NOT_RUNNING
		fi
	fi
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	${mysql} -A -u ${DB_U} -p${DB_P}  ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'exit'
	if ( [ "$?" = "0" ] )
	then
		/bin/echo "ALIVE"
	else
		/bin/echo "DEAD"
		/bin/echo "${0} `/bin/date`: The mysql database has been offline, I am atempting to restart it" 
		${HOME}/providerscripts/email/SendEmail.sh "DATABASE HAS BEEN OFFLINE" "THe mysql database has been offline" "ERROR"
		${HOME}/utilities/processing/RunServiceCommand.sh mysql restart

		if ( [ "$?" != "0" ] )
		then
			/bin/touch ${HOME}/runtime/DATABASE_NOT_RUNNING
			/bin/echo "${0} `/bin/date`: Couldn't restart the mysql database this is a problem that needs to be looked into"
			${HOME}/providerscripts/email/SendEmail.sh "DATABASE MIGHT NOT BE RUNNING" "I think that your mysql database might not be running" "ERROR"       
		else
			/bin/rm ${HOME}/runtime/DATABASE_NOT_RUNNING
		fi
	fi
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	export PGPASSWORD="${DB_P}" && /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} ${DB_N} -c "\q"
	if ( [ "$?" = "0" ] )
	then
		/bin/echo "ALIVE"
	else
		/bin/echo "DEAD"
		/bin/echo "${0} `/bin/date`: The postgres database has been offline, I am atempting to restart it" 
		${HOME}/providerscripts/email/SendEmail.sh "DATABASE HAS BEEN OFFLINE" "THe postgres database has been offline" "ERROR"

		${HOME}/utilities/processing/RunServiceCommand.sh postgresql restart

		if ( [ "$?" != "0" ] )
		then
			/bin/touch ${HOME}/runtime/DATABASE_NOT_RUNNING
			/bin/echo "${0} `/bin/date`: Couldn't restart the postgres database this is a problem that needs to be looked into" 
			${HOME}/providerscripts/email/SendEmail.sh "DATABASE MIGHT NOT BE RUNNING" "I think that your postgres database might not be running" "ERROR"        
		else
			/bin/rm ${HOME}/runtime/DATABASE_NOT_RUNNING
		fi
	fi
fi





