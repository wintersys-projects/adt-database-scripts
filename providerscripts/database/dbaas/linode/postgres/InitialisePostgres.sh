#!/bin/sh
############################################################################
# Description: This script initialises the Postgres db instance ready for use.
# Once this script has run, an empty database with a known name will have been
# created along with our database username and password. 
# Author: Peter Winter
# Date: 15/01/2017
############################################################################
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
#################################################################################
#################################################################################
set -x

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
    HOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

IP_MASK="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

DB_U="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`/bin/echo ${DB_U} | /bin/grep ':::'`" != "" ] )
then
    DB_U1="`/bin/echo ${DB_U} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $1}'`"
    DB_U2="`/bin/echo ${DB_U} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $2}'`"
fi

if ( [ "`/bin/echo ${DB_P} | /bin/grep ':::'`" != "" ] )
then
    DB_P1="`/bin/echo ${DB_P} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $1}'`"
    DB_P2="`/bin/echo ${DB_P} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $2}'`"
fi

if ( [ ! -d ${HOME}/runtime/postgres-init ] )
then
    /bin/mkdir -p ${HOME}/runtime/postgres-init
fi

/bin/cp ${HOME}/providerscripts/database/dbaas/linode/postgres/live/postgres-user.sql ${HOME}/runtime/postgres-init/initialiseDB-user.sql
/bin/cp ${HOME}/providerscripts/database/dbaas/linode/postgres/live/postgres-db.sql ${HOME}/runtime/postgres-init/initialiseDB.sql
/bin/sed -i "s/XXXXDB_UXXXX/${DB_U2}/g" ${HOME}/runtime/postgres-init/initialiseDB.sql
/bin/sed -i "s/XXXXDB_NXXXX/${DB_N}/g" ${HOME}/runtime/postgres-init/initialiseDB.sql
/bin/sed -i "s/XXXXHOSTXXXX/${HOST}/g" ${HOME}/runtime/postgres-init/initialiseDB.sql
/bin/sed -i "s/XXXXDB_UXXXX/${DB_U2}/g" ${HOME}/runtime/postgres-init/initialiseDB-user.sql
/bin/sed -i "s/XXXXDB_PXXXX/${DB_P2}/g" ${HOME}/runtime/postgres-init/initialiseDB-user.sql

${HOME}/providerscripts/utilities/remote/ConnectToPostgres.sh "dbaas-init" < ${HOME}/runtime/postgres-init/initialiseDB-user.sql
${HOME}/providerscripts/utilities/remote/ConnectToPostgres.sh "dbaas-init" < ${HOME}/runtime/postgres-init/initialiseDB.sql

${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'DBUSERNAME' "${DB_U2}"       
${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'DBPASSWORD' "${DB_P2}"   
