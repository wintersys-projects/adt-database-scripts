#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script which backups up the application  DB to
# the application datastore. 
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

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLED_SUCCESSFULLY"`" = "0" ] )
then
	exit
fi

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
BUILD_ARCHIVCE_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVCECHOICE'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"

period="`/bin/echo $1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
allowed_periods="hourly daily weekly monthly bimonthly shutdown"
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

cd ${HOME}/backups
${HOME}/providerscripts/database/BackupDatabase.sh ${websiteDB}
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

db_backup="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"

${HOME}/providerscripts/datastore/MountDatastore.sh "${db_backup}"

if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${db_backup}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP`" != "" ] )
then
	${HOME}/providerscripts/datastore/DeleteFromDatastore.sh "${db_backup}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
fi

if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${db_backup}/${WEBSITE_NAME}-DB-backup.tar.gz`" != "" ] )
then
	${HOME}/providerscripts/datastore/MoveDatastore.sh "${db_backup}/${WEBSITE_NAME}-DB-backup.tar.gz" "${db_backup}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
fi

/bin/systemd-inhibit --why="Persisting database to datastore" ${HOME}/providerscripts/datastore/PutToDatastore.sh "${websiteDB}" "${db_backup}" "no"

backup_name="`/bin/echo ${websiteDB} | /usr/bin/awk -F'/' '{print $NF}'`"
${HOME}/providerscripts/datastore/GetFromDatastore.sh  "${db_backup}/${backup_name}"

if ( ( [ ! -f ./${backup_name} ] || [ "`/usr/bin/diff ${websiteDB} ./${backup_name}`" != "" ] ) && [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
	/bin/echo "${0} `/bin/date`: Inconsistent backup `/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${backup_name}" 
	${HOME}/providerscripts/email/SendEmail.sh "${period} database backup FAILED" "A database backup has failed (inconsistent or non existent backup)..." "ERROR"
fi

/bin/rm ./${backup_name} ${websiteDB}
