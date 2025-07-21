#!/bin/sh
################################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# This script will take a deployed application and create a baseline out of the current version.
# It does this by making custom attributes and settings as generic as possible
#################################################################################################
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
##########################################################################################
##########################################################################################
#set -x

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "${1}" = "" ] )
then
	/bin/echo "Your application type is set to: `${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"
	/bin/echo "Please make very sure this is correct for your application otherwise things will break"
	/bin/echo "Press <enter> when you are sure"
	read x

	/bin/echo "Please enter a unique identifier for your baseline and make sure you have created a repository with the name <identifier>-db-baseline with your repository provider"
	read baseline_name
else
	baseline_name="${1}"
fi

if ( [ "${baseline_name}" = "" ] )
then
	/bin/echo "Identifier can't be blank"
	exit
fi

/bin/echo "Creating baseline of your database"

if ( [ ! -d ${HOME}/logs/backups ] )
then
	/bin/mkdir -p ${HOME}/logs/backups
fi

if ( [ "${1}" != "" ] )
then
	/bin/echo "with the following logs available on your database server"
	#The log files for the server build are written here...
	log_file="baseline_out_`/bin/date | /bin/sed 's/ //g'`"
	err_file="baseline_err_`/bin/date | /bin/sed 's/ //g'`"

	/bin/echo "Log file is at: ${HOME}/logs/backups/${log_file}"
	/bin/echo "Error file is at: ${HOME}/logs/backups/${err_file}"

	exec 1>>${HOME}/logs/backups/${log_file}
	exec 2>>${HOME}/logs/backups/${err_file}
fi

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d'.' -f2-`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"

if ( [ ! -d ${HOME}/backups ] )
then
	/bin/mkdir -p ${HOME}/backups
fi

/bin/rm -r ${HOME}/backups/* 2>/dev/null
if ( [ -d ${HOME}/.git ] )
then
	/bin/rm -r ${HOME}/.git
fi

APPLICATION_REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
#websiteDB="${HOME}/backups/${WEBSITE_NAME}-DB-backup".tar.gz

if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-db-baseline 2>&1 | /bin/grep 'Repository not found'`" != "" ] )
then
	if ( [ "${1}" = "" ] )
	then
		/bin/echo "Repository not found, do you want me to create one () (Y|y)"
		read response
		if ( [ "`/bin/echo "Y y" | /bin/grep ${response}`" != "" ] )
		then
			/bin/echo "Creating a new repository"
			${HOME}/providerscripts/git/CreateRepository.sh ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${baseline_name}-db-baseline ${APPLICATION_REPOSITORY_PROVIDER}
			if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-db-baseline 2>&1 | /bin/grep 'Repository not found'`" = "" ] )
			then
				/bin/echo "Repository (${baseline_name}-db-baseline) successfully created"
				/bin/echo "Press <enter> to continue"
				read x
			else
				/bin/echo "Repository (${baseline_name}-db-baseline) not created I will need to exit"
				exit 1
			fi
		fi
	else
		${HOME}/providerscripts/git/CreateRepository.sh ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${baseline_name}-db-baseline ${APPLICATION_REPOSITORY_PROVIDER}
		if ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-db-baseline 2>&1 | /bin/grep 'Repository not found'`" = "" ] )
		then
			/bin/echo "Repository (${baseline_name}-db-baseline) successfully created"
		else
			/bin/echo "Repository (${baseline_name}-db-baseline) not created I will need to exit"
			exit 1
		fi
	fi
elif ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-db-baseline 2>&1`" = "" ] )
then
	/bin/echo "Suitable repo (${baseline_name}-db-baseline) found, press <enter> to continue"
	read x
elif ( [ "`${HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${baseline_name}-db-baseline 2>&1 | /bin/grep 'HEAD'`" != "" ] )
then
	/bin/echo "repository (${baseline_name}-db-baseline) found but its not empty. Please either empty the repository or delete it or rename it and allow this script to create a fresh one. Will exit now, please rerun me once this is actioned"
	exit 1
fi

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

cd ${HOME}/backups

. ${HOME}/providerscripts/database/PlainDumpDatabase.sh

${HOME}/application/branding/RemoveApplicationBranding.sh

#/bin/tar cvfz ${websiteDB} applicationDB.sql
#/bin/rm applicationDB.sql
#/usr/bin/split -b 10M -d ${websiteDB} "application-db-"
#/bin/rm ${websiteDB}
#/bin/mkdir baseline
#/bin/mv application-db* baseline
/bin/rm -r .git
/usr/bin/git init
/usr/bin/git config --global --add safe.directory ${HOME}/backups

if ( [ -f ./gitattibutes ] )
then
	/usr/bin/git add .gitattributes
fi

/usr/bin/git add .
/usr/bin/git commit -m "Baseline baby"
/usr/bin/git branch -M main

REPOSITORY_PROVIDER="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"

#You can add additional repository providers here if you want to create a baseline with a different provider
if ( [ "${REPOSITORY_PROVIDER}" = "bitbucket" ] )
then
	/usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${baseline_name}-db-baseline.git
elif ( [ "${REPOSITORY_PROVIDER}" = "github" ] )
then
	/usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@github.com/${APPLICATION_REPOSITORY_OWNER}/${baseline_name}-db-baseline.git
elif ( [ "${REPOSITORY_PROVIDER}" = "gitlab" ] )
then
	/usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${baseline_name}-db-baseline.git
fi

/usr/bin/git push -u -f origin main

/bin/echo ""
/bin/echo "========================================================================================================================================="
/bin/echo "I consider your baseline to be complete you should verify the repository ${baseline_name}-db-baseline with ${REPOSITORY_PROVIDER} for user: ${APPLICATION_REPOSITORY_USERNAME}" 
/bin/echo "========================================================================================================================================="

exit 0
