#!/bin/sh
#######################################################################################################
# Description: This script will install an application into a postgres Database
# It has rudimentary checking to see if the database has installed fully.
# Author: Peter Winter
# Date: 17/01/2017
#######################################################################################################
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

HOME="`/bin/cat /home/homedir.dat`"
DB_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
DB_U="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST=127.0.0.1
fi

#Arrange for and perform the installation of our database dump file into our postgres server
if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] )
then    
	/bin/sed -i "s/XXXXXXXXXX/${DB_U}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	IP_MASK="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
	/bin/sed -i "s/YYYYYYYYYY/${IP_MASK}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	olduser="`/bin/grep 'u........u' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /bin/sed 's/ /\n/g' | grep '^u........u$' | /usr/bin/head -1`"
	/bin/sed -i "s/${olduser}/${DB_U}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	export PGPASSWORD="${DB_P}"
        
	if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
	then
		${HOME}/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh
	fi
	${HOME}/providerscripts/utilities/remote/ConnectToPostgresDB.sh < ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
fi

#We can gain confidence that our database has installed correctly if our special marker table is there
if ( [ "`${HOME}/providerscripts/utilities/remote/ConnectToPostgresDB.sh "select exists ( select 1 from information_schema.tables where table_name='zzzz');" | /bin/grep -v 'exist' | /bin/grep -v '\-\-\-\-'  | /bin/grep -v 'row' | /bin/sed 's/ //g'`" = "t" ] || [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
	/bin/echo "${0} `/bin/date` : An application has been installed in the database, right on" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
	${HOME}/providerscripts/email/SendEmail.sh "DATABASE INSTALLATION HAS COMPLETED" "An application has been installed in your postgres database" "INFO"
	/bin/touch ${HOME}/runtime/DB_APPLICATION_INSTALLED
else
	${HOME}/providerscripts/email/SendEmail.sh "DATABASE INSTALLATION HAS FAILED" "An application has failed to install in your postgres database" "ERROR"
fi
