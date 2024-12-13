#!/bin/sh
####################################################################################
# Description: This script coordinates, based on provider, the installation and initialisation
# of the database that the application is going to be installed into. 
# Date: 18/11/2016
# Author: Peter Winter
####################################################################################
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
#####################################################################################
#####################################################################################
#set -x

if ( [ ! -d ${HOME}/credentials ] )
then
        /bin/mkdir ${HOME}/credentials
        /bin/chmod 700 ${HOME}/credentials
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    DBaaS_DBNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSDBNAME'`"
    DBaaS_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSPASSWORD'`"
    DBaaS_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSUSERNAME'`"

    /bin/echo "${DBaaS_DBNAME}" >>  ${HOME}/credentials/shit
    /bin/echo "${DBaaS_PASSWORD}" >>  ${HOME}/credentials/shit
    /bin/echo "${DBaaS_USERNAME}" >>  ${HOME}/credentials/shit
    
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
else
    rnd="n`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-8 | /usr/bin/tr '[:upper:]' '[:lower:]'`n"
    rnd1="p`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-8 | /usr/bin/tr '[:upper:]' '[:lower:]'`p"
    rnd2="u`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-8 | /usr/bin/tr '[:upper:]' '[:lower:]'`u"

    /bin/echo "${rnd}" > ${HOME}/credentials/shit
    /bin/echo "${rnd1}" >> ${HOME}/credentials/shit
    /bin/echo "${rnd2}" >> ${HOME}/credentials/shit

    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ]  )
then
    DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
    DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
    DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"
else
    DB_N="`/bin/sed '1q;d' ${HOME}/credentials/shit`"
    DB_P="`/bin/sed '2q;d' ${HOME}/credentials/shit`"
    DB_U="`/bin/sed '3q;d' ${HOME}/credentials/shit`"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ]  )
then
    . ${HOME}/providerscripts/database/singledb/mariadb/InstallMariaDB.sh
    . ${HOME}/providerscripts/database/singledb/mariadb/InitialiseMariaDB.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    . ${HOME}/providerscripts/database/singledb/postgres/InstallPostgresDB.sh
    . ${HOME}/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    . ${HOME}/providerscripts/database/singledb/mysql/InstallMySQLDB.sh
    . ${HOME}/providerscripts/database/singledb/mysql/InitialiseMySQLDB.sh
fi

${HOME}/providerscripts/email/SendEmail.sh "A single node database has been started" "a single node database has been started and initialised" "INFO"

/bin/touch ${HOME}/runtime/DB_INITIALISED
