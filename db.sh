#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : This script is the main script for building a database server.
# It is called remotely from the "BuildDatabase" script of the build machine. 
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

#Get ourselves orientated so that we know where our home is
USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
export HOME="/home/${USER_HOME}" | /usr/bin/tee -a ~/.bashrc

/bin/echo "set mouse=r" > /root/.vimrc

#Set the intialial permissions for the build
/usr/bin/find ${HOME} -not -path '*/\.*' -type d -print0 | xargs -0 chmod 0755 # for directories
/usr/bin/find ${HOME} -not -path '*/\.*' -type f -print0 | xargs -0 chmod 0500 # for files
/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
/bin/chmod 750 ${HOME}/.ssh

/bin/echo 'export HOME=`/bin/cat /home/homedir.dat` && /bin/sh ${1} ${2} ${3} ${4} ${5} ${6}' > /usr/bin/run
/bin/chown ${SERVER_USER}:root /usr/bin/run
/bin/chmod 750 /usr/bin/run

if ( [ ! -d ${HOME}/logs/initialbuild ] )
then
    /bin/mkdir -p ${HOME}/logs/initialbuild
fi

if ( [ ! -d ${HOME}/super ] )
then
    /bin/mkdir ${HOME}/super
fi

if ( [ ! -d ${HOME}/.ssh ] )
then
        /bin/mkdir ${HOME}/.ssh
        /bin/chmod 700 ${HOME}/.ssh
fi

if ( [ ! -d ${HOME}/runtime ] )
then
        /bin/mkdir -p ${HOME}/runtime
        /bin/chown ${SERVER_USER}:${SERVER_USER} ${HOME}/runtime
        /bin/chmod 755 ${HOME}/runtime
fi

SERVER_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

/bin/mv ${HOME}/providerscripts/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

out_file="initialbuild/database-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/database-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}


#CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
#AUTOSCALERIP="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ASIP'`"
#BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
#BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
#ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
#WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
#WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
BASELINE_DB_REPOSITORY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"
#INFRASTRUCTURE_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
#INFRASTRUCTURE_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
#INFRASTRUCTURE_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPASSWORD'`"
##INFRASTRUCTURE_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
##APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
#APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
#APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
#APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
#DATABASE_INSTALLATION_TYPE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DATABASEINSTALLATIONTYPE'`"
GIT_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
GIT_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
#SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
#SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
#SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"

#Non standard variable settings
#WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
#WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
#ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
#WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
#WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"


#Initialise Git
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch main
/usr/bin/git config --global pull.rebase false 


${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'IPMASK' "`${HOME}/providerscripts/utilities/processing/GetIP.sh | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`.%.%"
${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'MYIP' "`${HOME}/providerscripts/utilities/processing/GetIP.sh`" 
${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'MYPUBLICIP' "`${HOME}/providerscripts/utilities/processing/GetPublicIP.sh`" 

/bin/echo "${0} Setting up firewall"
${HOME}/security/SetupFirewall.sh

cd ${HOME}


/bin/echo "${0} Initialising Datastore"
${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh
${HOME}/providerscripts/datastore/InitialiseAdditionalDatastoreConfigs.sh

cd ${HOME}

count="0"
while ( [ ! -f ${HOME}/runtime/DATABASE_SYSTEM_INSTALLED ] && [ "${count}" -lt "71" ] )
do
        /bin/sleep 2
        count="`/usr/bin/expr ${count} + 1`"
done

if ( [ "${count}" = "71" ] )
then
        :
        ###Send Email and Log Message
fi



/bin/echo "${0} Initialising Database"
${HOME}/providerscripts/database/InitialiseDatabase.sh

BYPASS_DB_LAYER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BYPASSDBLAYER'`"
if ( [ "${BYPASS_DB_LAYER}" != "1" ] )
then
    #...and install the application
    if ( [ "${BASELINE_DB_REPOSITORY_NAME}" != "VIRGIN" ] )
    then    
        /bin/echo "${0} Installing bespoke application"
        if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
        then
                ${HOME}/applicationdb/InstallApplicationDB.sh 
                ${HOME}/providerscripts/application/CustomiseApplication.sh
        else
                ${HOME}/applicationdb/InstallApplicationDB.sh 
        fi
    fi
fi

#Set userallow for fuse
/bin/sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf

# Configure the crontab
${HOME}/cron/InitialiseCron.sh

${HOME}/providerscripts/utilities/processing/UpdateIPs.sh
${HOME}/providerscripts/utilities/housekeeping/CleanupAfterBuild.sh
${HOME}/providerscripts/email/SendEmail.sh "A DATABASE HAS BEEN SUCCESSFULLY BUILT" "A Database has been successfully built and primed as is rebooting ready for use" "INFO"
/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
/usr/bin/touch ${HOME}/runtime/DATABASE_READY

${HOME}/providerscripts/utilities/security/EnforcePermissions.sh

${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &
