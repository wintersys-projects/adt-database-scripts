#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script which backups up the application  DB to
# the application git repository provider along with to the datastore if supersafe
# backups are enabled. 
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
##################################################################################
##################################################################################
#set -x

if ( [ "$1" = "" ] )
then
    /bin/echo "This script requires the <Build periodicity> parameter to be set"
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLEDSUCCESSFULLY"`" = "0" ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    exit
fi

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

#Non standard variables
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

period="`/bin/echo $1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
allowed_periods="hourly daily weekly monthly bimonthly"
if ( [ "`/bin/echo ${allowed_periods} | /bin/grep ${period}`" = "" ] )
then
        /bin/echo "Invalid periodicity passed to backup script"
        exit
fi

if ( [ ! -d ${HOME}/backups ] )
then
    /bin/mkdir -p ${HOME}/backups
fi

/bin/rm -r ${HOME}/backups/*

websiteDB="${HOME}/backups/${WEBSITE_NAME}-DB-backup".tar.gz

DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

cd ${HOME}/backups
. ${HOME}/providerscripts/database/BackupDatabase.sh
cd ${HOME}/backups

if ( [ ! -d ${HOME}/backups/${period} ] )
then
    /bin/mkdir ${HOME}/backups/${period}
fi

if ( [ -f ${WEBSITE_NAME}-db* ] )
then
        /bin/mv *${WEBSITE_NAME}-db* ${HOME}/backups/${period}
fi

cd ${HOME}/backups/

${HOME}/providerscripts/datastore/MountDatastore.sh "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"
${HOME}/providerscripts/datastore/DeleteFromDatastore.sh "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
${HOME}/providerscripts/datastore/MoveDatastore.sh "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
/bin/systemd-inhibit --why="Persisting database to datastore" ${HOME}/providerscripts/datastore/PutToDatastore.sh "${websiteDB}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"
backup_name="`/bin/echo ${websiteDB} | /usr/bin/awk -F'/' '{print $NF}'`"
${HOME}/providerscripts/datastore/GetFromDatastore.sh  "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${backup_name}"

if ( [ ! -f ./${backup_name} ] || [ "`/usr/bin/diff ${websiteDB} ./${backup_name}`" != "" ] )
then
    /bin/echo "${0} `/bin/date`: Inconsistent backup `/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${backup_name}" >> ${HOME}/logs/backups/OPERATIONAL_MONITORING.log
    ${HOME}/providerscripts/email/SendEmail.sh "${period} database backup FAILED" "A database backup has failed (inconsistent or non existent backup)..." "ERROR"
fi
/bin/rm ./${backup_name}
