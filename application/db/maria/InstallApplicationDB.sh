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

CLOUDHOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"

HOST=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

BUILD_ARCHIVE_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"

${HOME}/application/db/maria/CustomiseMariaByApplication.sh

if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] )
then
	currentengine="`/bin/grep ENGINE= ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /usr/bin/awk -F' ' '{print $2}' | /usr/bin/head -1`"
	# We are a mysql cluster so we need to use NDB engine type the way to do this is to modify the dump file
	/bin/sed -i "s/${currentengine}/ENGINE=INNODB /g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql

	#Make any mods that we want first for self managed and then for managed
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
	then
		/bin/sed -i '/SESSION.SQL_LOG_BIN/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/sql_require_primary_key/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/^\[mysqld\]/a character-set-server = utf8mb4' /etc/mysql/my.cnf
		/bin/sed -i '/^\[mysqld\]/a collation-server = utf8mb4_bin' /etc/mysql/my.cnf        
	elif ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] && ( [ "${CLOUDHOST}" = "digitalocean" ] || [ "${CLOUDHOST}" = "exoscale" ] || [ "${CLOUDHOST}" = "linode" ] || [ "${CLOUDHOST}" = "vultr" ] ) )
	then
		/bin/sed -i 's/.*sql_require_primary_key.*/SET sql_require_primary_key=0;/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/SESSION.SQL_LOG_BIN/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql

		if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
		then
			if ( [ "`/bin/grep GTID ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql`" != "" ] )
			then
				/bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
				/bin/sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
			fi
		fi
	fi

	#Install the actual database by connecting the the mariadb instance and passing in the database dump that we have worked hard to have
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
	then
		/usr/bin/mariadb -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port=${DB_PORT} -e "CREATE DATABASE ${DB_N};"
		/bin/sed -i 's/.*sql_require_primary_key.*/SET sql_require_primary_key=0;/g' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
		/bin/sed -i '/GTID_PURGED/d' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	fi
	${HOME}/utilities/remote/ConnectToMySQLDB.sh < ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
	exit
fi 

#Make sure all tables are set to INNODB in our new database
${HOME}/application/db/maria/EnforceEngineType.sh &

#And so we can gain confidence that our database has installed correctly by looking for our special marker table
if ( [ "`${HOME}/utilities/remote/ConnectToMySQLDB.sh 'show tables' | /bin/grep 'zzzz'`" != "" ] )
then
	/bin/echo "Successfully installed a new application into the database"
	${HOME}/providerscripts/email/SendEmail.sh "A new application has been installed in your database" "A new application has been installed in your database" "INFO"
	/bin/touch ${HOME}/runtime/DB_APPLICATION_INSTALLED
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
	/bin/echo "Failed to install a new application into the database"
	exit
fi
