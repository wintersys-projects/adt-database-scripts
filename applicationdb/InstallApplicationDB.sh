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
        if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
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

DB_U="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
BASELINE_DB_REPOSITORY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"


if ( [ "${BUILD_ARCHIVE_CHOICE}" = "" ] )
then
        BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
fi

#if ( [ -d ${HOME}/installer ] )
#then
#        /bin/rm -r ${HOME}/installer/*
#fi

if ( [ ! -d ${HOME}/installer/${BUILD_ARCHIVE_CHOICE} ] )
then
        /bin/mkdir -p ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}
fi

while ( [ "`/bin/ls ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/ | /usr/bin/wc -l 2>/dev/null`" -lt "1" ] && [ ! -f ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz ] )
do
        if ( [ -f ${HOME}/installer/.git ] )
        then
                /bin/rm -r ${HOME}/installer/.git
                /bin/rm -r ${HOME}/installer/.git*
        fi
    
        if ( [ -d ${HOME}/installer ] )
        then
                /bin/rm -r ${HOME}/installer/*
        fi
    
        cd ${HOME}/installer

        #We don't do anything if we are a virgin, but, if we are a baseline then clone the database archvive and prepare it in the installer directory
        if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
        then
                ${HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} "${BASELINE_DB_REPOSITORY_NAME}" .
                /bin/cat ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/application-db-?? > ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/application-db
                /bin/mv ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/application-db ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/application-db-00
        elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
        then
                #if we are here then we are a temporal backup so get the database archive fron the datastore and prepare it
                if ( [ ! -f ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-* ] )
                then
                        ${HOME}/providerscripts/datastore/GetFromDatastore.sh "`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-db-${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-DB-backup.tar.gz"
                elif ( [ -f ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-00 ] )
                then
                        /bin/mv ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-00 ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz
                fi
       
                if ( [ -f  ${HOME}/installer/${WEBSITE_NAME}-DB-backup.tar.gz ] && [ ! -f ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz ] )
                then
                        /bin/mv ${HOME}/installer/${WEBSITE_NAME}-DB-backup.tar.gz ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz
                fi
                if ( [ -f ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-* ] )
                then
                        /bin/rm ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db-*
                fi
        fi
done

/bin/mkdir -p ${HOME}/backups/installDB/

#If we are virgin, do nothing otherwise extract the archive so we can "get at" the actual SQL that is going to populate our database
if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
        if ( [ -f ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/application-db* ] )
        then
                /bin/cat ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/application-db* > ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz
        fi

        if ( [ "`/bin/ls ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz | /usr/bin/wc -l`" = "1" ] )
        then
                /bin/tar xvfz ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz
                /bin/mv ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz  ${HOME}/backups/installDB/latestDB.tar.gz
        fi
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
        if ( [ -f ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db* ] )
        then
                /bin/cat ${HOME}/installer/${BUILD_ARCHIVE_CHOICE}/${WEBSITE_NAME}-db* > ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz
        fi

        if ( [ -f ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz ] )
        then
                /bin/tar xvfz ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz
                /bin/mv ${HOME}/installer/${WEBSITE_NAME}-DB-full.tar.gz  ${HOME}/backups/installDB/latestDB.tar.gz
        fi
fi

cd ${HOME}/backups/installDB

if ( [ "`/bin/ls ${HOME}/backups/installDB/latestDB.tar.gz`" != "" ] )
then
        /bin/tar xvfz latestDB.tar.gz
        /bin/mv application* ${WEBSITE_NAME}DB.sql
        if ( [ "`/bin/cat ${WEBSITE_NAME}DB.sql | /bin/wc -l`" -lt "10" ] && [ "`/bin/grep 'zzzz' ${WEBSITE_NAME}DB.sql`" = "" ] )
        then
                /bin/echo "Counldn't find a suitable database file. having to exit... The END"
                ${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "Couldn't find a suitable database dump file to install" "ERROR"
                exit
        fi
elif ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "Couldn't find a suitable database dump file to install" "ERROR"
        exit
fi

cd ${HOME}
/bin/rm -r ${HOME}/installer

#Apply the application branding that we need for this deployment and then install the archive we have obtained as our database 
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
        ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
        count="1" 
        while ( [ ! -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] && [ "${count}" -lt "5" ] )
        do
                #Install the application db into a maria database
                ${HOME}/applicationdb/maria/InstallApplicationDB.sh
                count="`/usr/bin/expr ${count} + 1`"
        done
fi
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
        ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
        count="1" 
        while ( [ ! -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] && [ "${count}" -lt "5" ] )
        do
                #Install the application db into a MySQL database
                ${HOME}/applicationdb/mysql/InstallApplicationDB.sh
                count="`/usr/bin/expr ${count} + 1`"
        done
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
        ${HOME}/providerscripts/application/branding/ApplyApplicationBranding.sh
        count="1" 
        while ( [ ! -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] && [ "${count}" -lt "5" ] )
        do
                #Install the application db into a Postgres database
                ${HOME}/applicationdb/postgres/InstallApplicationDB.sh
                count="`/usr/bin/expr ${count} + 1`"
        done
fi

# We reckon all is good if this file exists
if ( [ ! -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] )
then
        ${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR" "I don't think that the application installed correctly into the database" "ERROR"
fi
