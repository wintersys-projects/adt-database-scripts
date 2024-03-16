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

if ( [ "$1" = "" ] || [ "$2" = "" ] )
then
    /bin/echo "This script requires the <Build periodicity> and the <build identifier> parameters to be set"
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLEDSUCCESSFULLY"`" = "0" ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] || [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "INSTALLEDSUCCESSFULLY"`" = "0" ] )
then
    exit
fi

if ( [ ! -d ${HOME}/logs/backups ] )
then
    /bin/mkdir -p ${HOME}/logs/backups
fi

#The log files for the server build are written here...
log_file="backup_out_`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/backups/${log_file}
err_file="backup_err_`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/backups/${err_file}

DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"

#Non standard variables
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"


if ( [ ! -d ${HOME}/backups ] )
then
    /bin/mkdir -p ${HOME}/backups
fi

/bin/rm -r ${HOME}/backups/*

APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
SUPERSAFE_DB="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SUPERSAFEDB'`"


BUILD_IDENTIFIER="$2"

if ( [ "$1" = "HOURLY" ] )
then
    period="hourly"
fi
if ( [ "$1" = "DAILY" ] )
then
    period="daily"
fi
if ( [ "$1" = "WEEKLY" ] )
then
    period="weekly"
fi
if ( [ "$1" = "MONTHLY" ] )
then
    period="monthly"
fi
if ( [ "$1" = "BIMONTHLY" ] )
then
    period="bimonthly"
fi
if ( [ "$1" = "SHUTDOWN" ] )
then
   period="shutdown"
fi
if ( [ "$1" = "MANUAL" ] )
then
   period="manual"
fi


#Get the date as a unique timestamp for the backup

date="`/bin/date | /bin/sed 's/ //g'`"
/bin/echo "${0} `/bin/date`: Backing up database" >> ${HOME}/logs/backups/OPERATIONAL_MONITORING.log
websiteDB="${HOME}/backups/${WEBSITE_NAME}-DB-backup".tar.gz

DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

count="0"
while ( ( [ "${DB_N}" = "" ] || [ "${DB_U}" = "" ] || [ "${DB_P}" = "" ] ) && [ "${count}" -lt "20" ] )
do
    count="`/usr/bin/expr ${count} + 1`"
    /bin/sleep 10
    DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
    DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
    DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"
done

if ( [ "${count}" = "20" ] )
then
    ${HOME}/providerscripts/email/SendEmail.sh "Backup Failed" "Haven't been able to retrieve backup credentials, therefore, backup has failed" "ERROR"
    exit
fi


cd ${HOME}/backups

. ${HOME}/providerscripts/git/utilities/BackupDatabase.sh

cd ${HOME}/backups

count=0

if ( [ -d ${HOME}/backups/.git ] )
then
    /bin/rm -r ${HOME}/backups/.git
fi

/bin/rm ${HOME}/backups/${period}/*
/bin/rm -r ${HOME}/.git

if ( [ "${period}" = "manual" ] )
then
    if ( [ ! -d /tmp/backup_archive ] )
    then
        /bin/mkdir /tmp/backup_archive
    fi
    /bin/rm -r /tmp/backup_archive/*
    /bin/cp ${websiteDB} /tmp/backup_archive/${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}.tar.gz
elif ( [ "${SUPERSAFE_DB}" = "0" ]  || [ "${SUPERSAFE_DB}" = "1" ] )
then
    ${HOME}/providerscripts/git/DeleteRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
    ${HOME}/providerscripts/git/CreateRepository.sh "${APPLICATION_REPOSITORY_USERNAME}" "${APPLICATION_REPOSITORY_PASSWORD}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}" "${period}" "${BUILD_IDENTIFIER}" "${APPLICATION_REPOSITORY_PROVIDER}"
fi

/bin/sleep 10

#Create an archive of the master db
/usr/bin/split -b 100M -d ${websiteDB} "${WEBSITE_NAME}-db-"


if ( [ -d ${HOME}/backups/.git ] )
then
    /bin/rm -r ${HOME}/backups/.git
fi

cd ${HOME}/backups

/usr/bin/git init
/usr/bin/git config --global --add safe.directory ${HOME}/backups
/usr/bin/git add .gitattributes

if ( [ ! -d ${HOME}/backups/${period} ] )
then
    /bin/mkdir ${HOME}/backups/${period}
fi

/bin/mv *${WEBSITE_NAME}-db* ${HOME}/backups/${period}

cd ${HOME}/backups/

DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
inconsistentbackup="0"
if ( [ "${SUPERSAFE_DB}" = "1" ]  || [ "${SUPERSAFE_DB}" = "2" ] )
then
    ${HOME}/providerscripts/datastore/MountDatastore.sh "${DATASTORE_CHOICE}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"
    ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
    ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${WEBSITE_NAME}-DB-backup.tar.gz.BACKUP"
    /bin/systemd-inhibit --why="Persisting database to datastore" ${HOME}/providerscripts/datastore/PutToDatastore.sh "${DATASTORE_CHOICE}" "${websiteDB}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}"
    backup_name="`/bin/echo ${websiteDB} | /usr/bin/awk -F'/' '{print $NF}'`"
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${backup_name}"

    if ( [ ! -f ./${backup_name} ] || [ "`/usr/bin/diff ${websiteDB} ./${backup_name}`" != "" ] )
    then
        inconsistentbackup="1"
        /bin/touch ${HOME}/runtime/BACKUP_MISSING
        /bin/echo "${0} `/bin/date`: Inconsistent backup `/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${period}/${backup_name}" >> ${HOME}/logs/backups/OPERATIONAL_MONITORING.log
        ${HOME}/providerscripts/email/SendEmail.sh "${period} database backup FAILED" "A database backup has failed (inconsistent or non existent backup)..." "ERROR"
    fi
    /bin/rm ./${backup_name}
fi

if ( [ "${SUPERSAFE_DB}" = "0" ]  || [ "${SUPERSAFE_DB}" = "1" ] )
then
    /bin/systemd-inhibit --why="Persisting database to git repo" ${HOME}/providerscripts/git/GitPushDB.sh "." "Automated Backup" "${APPLICATION_REPOSITORY_PROVIDER}" "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}"
    if ( [ ! -d /tmp/verify/ ] )
    then
        /bin/mkdir -p /tmp/verify/
    fi

    /bin/rm -r /tmp/verify/* /tmp/verify/.*
    cd /tmp/verify
    /bin/sleep 10
    ${HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} "${WEBSITE_SUBDOMAIN}-${WEBSITE_NAME}-db-${period}-${BUILD_IDENTIFIER}" /tmp/verify
    /bin/mkdir -p /tmp/verify/${period}
    /bin/cat /tmp/verify/${period}/${WEBSITE_NAME}-db-?? > /tmp/verify/${period}/${WEBSITE_NAME}-DB-full.tar.gz
    /bin/tar xvfz /tmp/verify/${period}/${WEBSITE_NAME}-DB-full.tar.gz

    if ( [ "`/bin/grep "CREATE TABLE" /tmp/verify/applicationDB.sql | /bin/grep "zzzz"`" = "" ] || [ "${inconsistentbackup}" = "1" ] )
    then
        /bin/echo "${0} `/bin/date`: ${period} database backup FAILED" >> ${HOME}/logs/backups/OPERATIONAL_MONITORING.log
        /bin/touch ${HOME}/runtime/BACKUP_MISSING
        ${HOME}/providerscripts/email/SendEmail.sh "${period} database backup FAILED" "A database backup has failed (inconsistentbackup was set to ${inconsistentbackup} in the code) ... you might want to look into why...but in the meantime, trying to make another backup" "ERROR"
    else
        ${HOME}/providerscripts/email/SendEmail.sh "${period} database backup SUCCEEDED" "A database backup has successfully completed" "INFO"
    fi
fi


