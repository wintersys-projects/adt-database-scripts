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

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST=127.0.0.1
fi

if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] )
then    
    if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "dbinstalllock.file"`" = "0" ] )
    then
        /usr/bin/touch ${HOME}/runtime/dbinstalllock.file
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/dbinstalllock.file 
        /bin/sed -i "s/XXXXXXXXXX/${DB_U}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
        /bin/sed -i "s/YYYYYYYYYY/${IP_MASK}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        olduser="`/bin/grep 'u........u' ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /bin/sed 's/ /\n/g' | grep '^u........u$' | /usr/bin/head -1`"
        /bin/sed -i "s/${olduser}/${DB_U}/g" ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        export PGPASSWORD="${DB_P}"
        
        if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
        then
           . ${HOME}/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh
        fi
        
        /usr/bin/psql -h ${HOST} -U ${DB_U} -p ${DB_PORT} ${DB_N} < ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
        ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "dbinstalllock.file"
    else
        exit
    fi
fi

if ( [ "`/usr/bin/psql -h ${HOST} -p ${DB_PORT} -U ${DB_U} ${DB_N} -c "select exists ( select 1 from information_schema.tables where table_name='zzzz');" | /bin/grep -v 'exist' | /bin/grep -v '\-\-\-\-'  | /bin/grep -v 'row' | /bin/sed 's/ //g'`" = "t" ] || [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
    /bin/echo "${0} `/bin/date` : An application has been installed in the database, right on" >> ${HOME}/logs/BUILD_PROCESS_MONITORING.log
    ${HOME}/providerscripts/email/SendEmail.sh "DATABASE INSTALLATION HAS COMPLETED" "An application has been installed in your postgres database" "INFO"
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh APPLICATION_INSTALLED
else
    ${HOME}/providerscripts/email/SendEmail.sh "DATABASE INSTALLATION HAS FAILED" "An application has failed to install in your postgres database" "ERROR"
fi
