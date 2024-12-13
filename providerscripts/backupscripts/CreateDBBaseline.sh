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

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

if ( [ "${1}" = "" ] )
then
    /bin/echo "Your application type is set to: `${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'`"
    /bin/echo "Please make very sure this is correct for your application otherwise things will break"
    /bin/echo "Press <enter> when you are sure"
    read x
    
    /bin/echo "Please enter a unique identifier for your baseline and make sure you have created a repository with the name <identifier>-db-baseline with your repository provider"
    read baseline_name
else
    baseline_name="${1}"
fi

/bin/echo "Creating baseline of your database with the following logs available on your database server"

if ( [ ! -d ${HOME}/logs/backups ] )
then
    /bin/mkdir -p ${HOME}/logs/backups
fi

#The log files for the server build are written here...
log_file="baseline_out_`/bin/date | /bin/sed 's/ //g'`"
err_file="baseline_err_`/bin/date | /bin/sed 's/ //g'`"

/bin/echo "Log file is at: ${HOME}/logs/backups/${log_file}"
/bin/echo "Error file is at: ${HOME}/logs/backups/${err_file}"

exec 1>>${HOME}/logs/backups/${log_file}
exec 2>>${HOME}/logs/backups/${err_file}

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d'.' -f2-`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"

if ( [ ! -d ${HOME}/backups ] )
then
    /bin/mkdir -p ${HOME}/backups
fi

/bin/rm -r ${HOME}/backups/*
/bin/rm -r ${HOME}/.git

APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"


websiteDB="${HOME}/backups/${WEBSITE_NAME}-DB-backup".tar.gz

DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

cd ${HOME}/backups

. ${HOME}/providerscripts/git/database/PlainDumpDatabase.sh

. ${HOME}/providerscripts/application/branding/RemoveApplicationBranding.sh

IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"

/bin/sed -i "s/${IP_MASK}/YYYYYYYYYY/g" applicationDB.sql
/bin/tar cvfz ${websiteDB} applicationDB.sql
/bin/rm applicationDB.sql
/usr/bin/split -b 10M -d ${websiteDB} "application-db-"
/bin/rm ${websiteDB}
/bin/mkdir baseline
/bin/mv application-db* baseline
/bin/rm -r .git
/usr/bin/git init
/usr/bin/git config --global --add safe.directory ${HOME}/backups
/usr/bin/git add .gitattributes
/usr/bin/git add .
/usr/bin/git commit -m "Baseline baby"
/usr/bin/git branch -M main

REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"

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

exec 1>>/dev/tty

/bin/echo ""
/bin/echo "========================================================================================================================================="
/bin/echo "I consider your baseline to be complete you should verify the repository ${baseline_name}-db-baseline with ${REPOSITORY_PROVIDER} for user: ${APPLICATION_REPOSITORY_USERNAME}" 
/bin/echo "========================================================================================================================================="
