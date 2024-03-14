#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : This script will install the application DB for the database type that you have installed.
# It expects a database system to be online either locally or as a managed database at a remote location. 
# Your database dump file is expected to be available either in a repository or your datastore and if it is not
# available or it is damaged in some way, then, the installation will fail. 
# It has rudimentary checking that the application database has installed correctly and it will apply application
# branding to make your application flexible enough to work for differently domainnamed deployments to that which
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
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
    then
        exit
    fi
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "APPLICATION_INSTALLED"
    if ( [ -f ${HOME}/runtime/APPLICATION_INSTALLED ] )
    then
         /bin/rm ${HOME}/runtime/APPLICATION_INSTALLED
    fi
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/shit ${HOME}/.ssh/shit
    /bin/cp ${HOME}/.ssh/shit ${HOME}/credentials/shit
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "APPLICATION_INSTALLED"`" = "1" ]  || [ -f ${HOME}/runtime/APPLICATION_INSTALLED ] || [ ! -f ${HOME}/runtime/DB_INITIALISED ] )
then
    exit
fi

if ( [ "${DB_N}" = "" ] && [ "${DB_P}" = "" ] && [ "${DB_U}" = "" ] )
then
    DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
    DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
    DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"
fi

DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
BASELINE_DB_REPOSITORY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"

#Non standard variable extractions

ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d'.' -f2-`"
SUB_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME}  | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"


if ( [ "${BUILD_ARCHIVE_CHOICE}" = "" ] )
then
    BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
fi
if ( [ "${BUILD_IDENTFIER}" = "" ] )
then
    BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
fi

/bin/rm -r /installer

if ( [ ! -d /installer/${BUILD_ARCHIVE_CHOICE} ] )
then
    /bin/mkdir -p /installer/${BUILD_ARCHIVE_CHOICE}
fi

SUPERSAFE_DB="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'SUPERSAFEDB'`"

count=0
while ( ( [ "`/bin/ls /installer/${BUILD_ARCHIVE_CHOICE}/ | /usr/bin/wc -l`" -lt "1" ] && [ ! -f /installer/${WEBSITE_NAME}-DB-full.tar.gz ] ) && [ "${count}" != "5" ] )
do
    if ( [ -f /installer/.git ] )
    then
        /bin/rm -r /installer/.git
        /bin/rm -r /installer/.git*
    fi
    
    if ( [ -d /installer ] )
    then
         /bin/rm -r /installer/*
    fi
    
    cd /installer

    if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
    then
         if ( [ "${SUPERSAFE_DB}" = "0" ] || [ "${SUPERSAFE_DB}" = "1" ] )
         then
             ${HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} "${BASELINE_DB_REPOSITORY_NAME}" .

            /bin/cat /installer/${BUILD_ARCHIVE_CHOICE}/application-db-?? > /installer/${BUILD_ARCHIVE_CHOICE}/application-db
            /bin/mv /installer/${BUILD_ARCHIVE_CHOICE}/application-db /installer/${BUILD_ARCHIVE_CHOICE}/application-db-00
        fi

    elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
    then
       if ( [ "${SUPERSAFE_DB}" = "0" ] || [ "${SUPERSAFE_DB}" = "1" ] )
       then
           DB_REPOSITORY_NAME="${WEBSITE_NAME}-db-${BUILD_ARCHIVE_CHOICE}-${BUILD_IDENTIFIER}"
           ${HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} "${WEBSITE_SUBDOMAIN}-${DB_REPOSITORY_NAME}" .

           /bin/cat /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-?? > /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db
           /bin/rm /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-*
           /bin/mv /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-00
       fi
       if ( ( [ "${SUPERSAFE_DB}" = "1" ] && [ ! -f /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-* ] ) || [ "${SUPERSAFE_DB}" = "2" ] )
       then
           ${HOME}/providerscripts/datastore/GetFromDatastore.sh "${DATASTORE_CHOICE}" "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-DB-backup.tar.gz"
       elif ( [ -f /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-00 ] )
       then
           /bin/mv /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-00 /installer/${WEBSITE_NAME}-DB-full.tar.gz
       fi
       
       if ( [ -f  /installer/${WEBSITE_NAME}-DB-backup.tar.gz ] && [ ! -f /installer/${WEBSITE_NAME}-DB-full.tar.gz ] )
       then
           /bin/mv /installer/${WEBSITE_NAME}-DB-backup.tar.gz /installer/${WEBSITE_NAME}-DB-full.tar.gz
       fi
       
       /bin/rm /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-*
   fi
   count="`/usr/bin/expr ${count} + 1`"
done

everythingok="0"
    
if ( [ "${SUPERSAFE_DB}" = "0" ] )
then
    if ( [ "${count}" = "5" ] && [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
    then
        /bin/echo "FAILED TO RETRIEVE DB SOURCE FROM REPOSITORY"
        exit
    fi
elif ( [ "${SUPERSAFE_DB}" = "1" ] )
then
     if ( [ "${count}" = "5" ] && [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
     then
        /bin/echo "AM CONFIGURED TO TRY THE S3 DATASTORE SO WILL TRY THAT NEXT"
     else 
         everythingok="1"
     fi
elif ( ( [ "${SUPERSAFE_DB}" = "1" ] || [ "${SUPERSAFE_DB}" = "2" ] ) && [ "${everythingok}" = "0" ] )
then
     if ( [ ! -f  /installer/${WEBSITE_NAME}-DB-full.tar.gz ] && [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
     then
        /bin/echo "Will have to exit ... The END"
        exit
     fi
fi

/bin/mkdir -p ${HOME}/backups/installDB/

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
    if ( [ -f /installer/${BUILD_ARCHIVE_CHOICE}/application-db* ] )
    then
        /bin/cat /installer/${BUILD_ARCHIVE_CHOICE}/application-db* > /installer/${WEBSITE_NAME}-DB-full.tar.gz
    fi

    if ( [ "`/bin/ls /installer/${WEBSITE_NAME}-DB-full.tar.gz | /usr/bin/wc -l`" = "1" ] )
    then
        /bin/tar xvfz /installer/${WEBSITE_NAME}-DB-full.tar.gz
        /bin/mv /installer/${WEBSITE_NAME}-DB-full.tar.gz  ${HOME}/backups/installDB/latestDB.tar.gz
fi
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
    if ( [ -f /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db* ] )
    then
        /bin/cat /installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db* > /installer/${WEBSITE_NAME}-DB-full.tar.gz
    fi

    if ( [ -f /installer/${WEBSITE_NAME}-DB-full.tar.gz ] )
    then
        /bin/tar xvfz /installer/${WEBSITE_NAME}-DB-full.tar.gz
        /bin/mv /installer/${WEBSITE_NAME}-DB-full.tar.gz  ${HOME}/backups/installDB/latestDB.tar.gz
    fi
fi

cd ${HOME}/backups/installDB

if ( [ "`/bin/ls ${HOME}/backups/installDB/latestDB.tar.gz`" != "" ] )
then
    /bin/tar xvfz latestDB.tar.gz
    /bin/mv application* ${WEBSITE_NAME}DB.sql
    if ( [ "`/bin/cat ${WEBSITE_NAME}DB.sql | /bin/wc -l`" -lt "10" ] )
    then
       /bin/echo "Counldn't find a suitable database file. having to exit... The END"
       exit
    fi
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
    /bin/echo "Something went wrong with obtaining the DB archive, can't run without it.....The END"
    exit
fi

cd /root
/bin/rm -r /installer/*
    
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
    if ( [ "${1}" = "force" ] )
    then
        . ${HOME}/providerscripts/database/singledb/mariadb/AdjustAccessForSnapshot.sh
    fi
    . ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
    . ${HOME}/installscripts/InstallMariaDBClient.sh
    . ${HOME}/applicationdb/maria/InstallMariaDB.sh
fi
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
    if ( [ "${1}" = "force" ] )
    then
        . ${HOME}/providerscripts/database/singledb/mariadb/AdjustAccessForSnapshot.sh
    fi
    . ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
    . ${HOME}/installscripts/InstallMySQLClient.sh
    . ${HOME}/applicationdb/mysql/InstallMySQLDB.sh
fi
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
    if ( [ "${1}" = "force" ] )
    then
        . ${HOME}/providerscripts/database/singledb/postgres/AdjustAccessForSnapshot.sh
    fi
    . ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
    . ${HOME}/installscripts/InstallPostgresClient.sh
    . ${HOME}/applicationdb/postgres/InstallPostgresDB.sh
fi
