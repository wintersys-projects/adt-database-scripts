#!/bin/sh
###########################################################################################################
# Description: This script will perform a backup of the database when it is called from cron
# It is called at set periods from cron and if you want to call it manually you can look in the 
# directory ${BUILD_HOME}/helperscripts relating to making backups and baselines for how to backup
# your database manually.
# Look there for further explaination
# Date: 16/11/2016
# Author: Peter Winter
###########################################################################################################
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
####################################################################################
####################################################################################
#set -x

periodicity="${1}"

MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"

if ( [ "${MULTI_REGION}" = "1" ] )
then
	if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "DB_BACKUP_RUNNING"`" != "" ] )
	then
		if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/AgeOfDatastoreFile.sh "config" "DB_BACKUP_RUNNING"`" -gt "300" ] )
		then
			${HOME}/providerscripts/datastore/config/wrapper/DeleteFromDatastore.sh "config" "DB_BACKUP_RUNNING"
		fi
	fi

	/bin/sleep "`/usr/bin/shuf -i1-60 -n1`"

	if ( [ "`${HOME}/providerscripts/datastore/config/wrapper/ListFromDatastore.sh "config" "DB_BACKUP_RUNNING"`" != "" ] )
	then
		exit
	else
		${HOME}/providerscripts/datastore/config/wrapper/PutToDatastore.sh "config" "DB_BACKUP_RUNNING" "root" "yes"
	fi
fi

${HOME}/application/backupscripts/Backup.sh "${periodicity}"

if ( [ "${MULTI_REGION}" = "1" ] )
then
	/bin/sleep 300
	${HOME}/providerscripts/datastore/config/wrapper/DeleteFromDatastore.sh "config" "DB_BACKUP_RUNNING"
fi
