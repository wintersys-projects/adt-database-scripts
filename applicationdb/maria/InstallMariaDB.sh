#!/bin/sh
########################################################################################################
# Description: This script will install an application SQL codebase into a MariaDB Database
# Author: Peter Winter
# Date: 17/01/2017
########################################################################################################
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

CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
DB_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

/bin/echo "${0} `/bin/date`: 2" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
${HOME}/applicationdb/maria/CustomiseMariaByApplication.sh
   
if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] )
then
	currentengine="`/bin/grep ENGINE= ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /usr/bin/awk -F' ' '{print $2}' | /usr/bin/head -1`"
	# We are a mysql cluster so we need to use NDB engine type the way to do this is to modify the dump file
	/bin/sed -i "s/${currentengine}/ENGINE=INNODB /g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    
	if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
	then
		/bin/sed -i '/SESSION.SQL_LOG_BIN/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/sql_require_primary_key/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/^\[mysqld\]/a character-set-server = utf8mb4' /etc/mysql/my.cnf
		/bin/sed -i '/^\[mysqld\]/a collation-server = utf8mb4_bin' /etc/mysql/my.cnf        
	elif ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] && ( [ "${CLOUDHOST}" = "digitalocean" ] || [ "${CLOUDHOST}" = "exoscale" ] || [ "${CLOUDHOST}" = "linode" ] || [ "${CLOUDHOST}" = "vultr" ] ) )
	then
		/bin/sed -i 's/.*sql_require_primary_key.*/SET sql_require_primary_key=0;/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/SESSION.SQL_LOG_BIN/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		
		if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
		then
			if ( [ "`/bin/grep GTID ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql`" != "" ] )
			then
				/bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
				/bin/sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
			fi
		fi
	fi

	#Not sure why but sometimes installation of the application is truncated leaving only a partial set of tables installed
	#so try installing it several in the hope that one succeeds

	if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "dbinstalllock.file"`" = "0" ] )
	then
		/usr/bin/touch ${HOME}/runtime/dbinstalllock.file
		${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/dbinstalllock.file 

		if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
		then
			/usr/bin/mariadb -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port=${DB_PORT} -e "CREATE DATABASE ${DB_N};"
			/bin/sed -i 's/.*sql_require_primary_key.*/SET sql_require_primary_key=0;/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
			/bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		fi
		${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh < ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "dbinstalllock.file"
	else
		exit
	fi
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "DATABASE INSTALLATION HAS FAILED" "Please review your logs as the system has failed to install your database application" "ERROR"
	exit
fi 

${HOME}/applicationdb/maria/EnforceEngineType.sh &

if ( [ "`${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh 'show tables' | /bin/grep 'zzzz'`" != "" ] )
then
	/bin/echo "Successfully installed a new application into the database"
	${HOME}/providerscripts/email/SendEmail.sh "A new application has been installed in your database" "A new application has been installed in your database" "INFO"
	/bin/touch ${HOME}/runtime/DB_APPLICATION_INSTALLED
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
	/bin/echo "Failed to install a new application into the database"
	${HOME}/providerscripts/email/SendEmail.sh "Failed to install a new application in the database" "Failed to install a new application in your database" "ERROR"
	exit
fi
