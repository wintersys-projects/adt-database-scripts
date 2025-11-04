#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : This script will install the application DB for the database type that you have installed.
# It expects a database system to be online either locally or as a managed database at a remote location. 
# Your database dump file is expected to be available either in a repository (if you are installing a baseline) or 
# in your datastore if you are making a temporal backup based deployment. If the database archive is damaged in any
# way then the installation of your application's database will fail. 
# It has rudimentary checking that the application database has installed correctly and it will apply application
# branding to make your application flexible enough to work for differently domain named deployments to that which
# your application was originally built as making it possible for your application to be built by you for your domain
# name but deployed by 3rd parties with a different domain name
#################################################################################################################
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

if ( [ "${HOME}" = "" ] )
then
	export HOME="`/bin/cat /home/homedir.dat`"
fi

if ( [ "${1}" = "force" ] )
then
	if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
	then
		exit
	fi

	if ( [ -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] )
	then
		/bin/rm ${HOME}/runtime/DB_APPLICATION_INSTALLED
	fi
fi


if ( [ -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] || [ ! -f ${HOME}/runtime/DB_INITIALISED ] )
then
	exit
fi

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_TOKEN="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYTOKEN'`"
BASELINE_DB_REPOSITORY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"


if ( [ "${BUILD_ARCHIVE_CHOICE}" = "" ] )
then
	BUILD_ARCHIVE_CHOICE="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
fi

if ( [ ! -d ${HOME}/backups/installDB ] )
then
	/bin/mkdir -p ${HOME}/backups/installDB
else
	/bin/rm -r ${HOME}/backups/installDB/* 2>/dev/null
fi

cd ${HOME}/backups/installDB

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
	${HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_OWNER} "${BASELINE_DB_REPOSITORY_NAME}" ${APPLICATION_REPOSITORY_TOKEN}
	if ( [ -f ${HOME}/backups/installDB/*baseline*/applicationDB.sql ] )
	then
		/bin/mv ${HOME}/backups/installDB/*baseline*/applicationDB.sql ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	elif ( [ -f ${HOME}/backups/installDB/*baseline*/applicationDB.psql ] )
	then
		/bin/mv ${HOME}/backups/installDB/*baseline*/applicationDB.psql ${HOME}/backups/installDB/${WEBSITE_NAME}DB.psql
	else
		/bin/echo "Counldn't find a suitable database file baseline. Have got to die"
		${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "Couldn't find a suitable database file baseline" "ERROR"
		exit
	fi
	/bin/rm -r ${HOME}/backups/installDB/*baseline*
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
	${HOME}/providerscripts/datastore/GetFromDatastore.sh "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-DB-backup.tar.gz"
	if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}-DB-backup.tar.gz ] )
	then
		/bin/tar xvfz ${HOME}/backups/installDB/${WEBSITE_NAME}-DB-backup.tar.gz -C ${HOME}/backups/installDB
		/bin/rm ${HOME}/backups/installDB/${WEBSITE_NAME}-DB-backup.tar.gz
	fi
	if ( [ -f ${HOME}/backups/installDB/applicationDB.sql ] )
	then
		/bin/mv ${HOME}/backups/installDB/applicationDB.sql ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	elif ( [ -f ${HOME}/backups/installDB/applicationDB.psql ] )
	then
		/bin/mv ${HOME}/backups/installDB/applicationDB.psql ${HOME}/backups/installDB/${WEBSITE_NAME}DB.psql
	else
		/bin/echo "Counldn't find a suitable database file backup. Have got to die"
		${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "Couldn't find a suitable database file backup" "ERROR"
		exit
	fi
fi

if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] && [ "`/usr/bin/tail -n 1 ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /bin/grep 'zzzz'`" = "" ] )
then
	/bin/echo "Counldn't find a suitable database file. have got to die"
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "Couldn't find a suitable database dump file to install" "ERROR"
	exit
fi

if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.psql ] && [ "`/usr/bin/tail -n 1 ${HOME}/backups/installDB/${WEBSITE_NAME}DB.psql | /bin/grep 'zzzz'`" = "" ] )
then
	/bin/echo "Counldn't find a suitable database file. have got to die"
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "Couldn't find a suitable database dump file to install" "ERROR"
	exit
fi

cd ${HOME}

#Apply the application branding that we need for this deployment and then install the archive we have obtained as our database 
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
	${HOME}/application/branding/ApplyApplicationBranding.sh
	${HOME}/application/db/maria/InstallApplicationDB.sh

fi
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	${HOME}/application/branding/ApplyApplicationBranding.sh
	${HOME}/application/db/mysql/InstallApplicationDB.sh
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	${HOME}/application/branding/ApplyApplicationBranding.sh
	${HOME}/application/db/postgres/InstallApplicationDB.sh
fi



# We reckon all is good if this file exists
if ( [ ! -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "DEFINITE INSTALLATION ERROR" "The application didn't install correctly into the database system" "ERROR"
fi
