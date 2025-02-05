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

#/usr/bin/find ${HOME} -not -path '*/\.*' -type d -print0 | xargs -0 chmod 0755 # for directories
#/usr/bin/find ${HOME} -not -path '*/\.*' -type f -print0 | xargs -0 chmod 0500 # for files
#/bin/chown ${SERVER_USER}:root ${HOME}/.ssh
#/bin/chmod 750 ${HOME}/.ssh

export HOMEDIR=${HOME}
/bin/echo "${HOMEDIR}" > /home/homedir.dat
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

if ( [ -f ${HOME}/.ssh/database_configuration_settings.dat ] )
then
	/bin/cp ${HOME}/.ssh/database_configuration_settings.dat ${HOME}/runtime/database_configuration_settings.dat
 	/bin/mv ${HOME}/.ssh/database_configuration_settings.dat ${HOME}/.ssh/database_configuration_settings.dat.original
  	/bin/chown ${SERVER_USER}:root ${HOME}/.ssh/database_configuration_settings.dat.original
   	/bin/chmod 400 ${HOME}/.ssh/database_configuration_settings.dat.original
	/bin/chown ${SERVER_USER}:root ${HOME}/runtime/database_configuration_settings.dat
	/bin/chmod 640 ${HOME}/runtime/database_configuration_settings.dat
fi

if ( [ -f ${HOME}/.ssh/buildstyles.dat ] )
then
	/bin/cp ${HOME}/.ssh/buildstyles.dat ${HOME}/runtime/buildstyles.dat
 	/bin/mv ${HOME}/.ssh/buildstyles.dat ${HOME}/.ssh/buildstyles.dat.original
    	/bin/chown ${SERVER_USER}:root ${HOME}/.ssh/buildstyles.dat.original
   	/bin/chmod 400 ${HOME}/.ssh/buildstyles.dat.original
	/bin/chown ${SERVER_USER}:root ${HOME}/runtime/buildstyles.dat
	/bin/chmod 640 ${HOME}/runtime/buildstyles.dat
fi

/bin/mv ${HOME}/providerscripts/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

if ( [ -f ${HOME}/InstallGit.sh ] )
then
    /bin/rm ${HOME}/InstallGit.sh
fi

out_file="initialbuild/database-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/database-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Building a new database server" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Settting up build parameters" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
#AUTOSCALERIP="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ASIP'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"
ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_DISPLAY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
BASELINE_DB_REPOSITORY_NAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"
INFRASTRUCTURE_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPROVIDER'`"
INFRASTRUCTURE_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYUSERNAME'`"
INFRASTRUCTURE_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYPASSWORD'`"
INFRASTRUCTURE_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'INFRASTRUCTUREREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_PROVIDER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'`"
APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"
APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
DATABASE_INSTALLATION_TYPE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'DATABASEINSTALLATIONTYPE'`"
GIT_USER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
GIT_EMAIL_ADDRESS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"
BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
SSH_PORT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SSHPORT'`"

#Non standard variable settings
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"

#ALGORITHM="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'ALGORITHM'`"
#BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"

#if ( [ ! -f ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ] )
#then
#	if ( [ -f /etc/ssh/ssh_host_rsa_key ] )
 #	then
  #		/bin/cp /etc/ssh/ssh_host_rsa_key ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}
#		/bin/chmod 600 ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}
#	fi
 #	if ( [ -f /etc/ssh/ssh_host_rsa_key.pub ] )
 #	then
  #		/bin/cp /etc/ssh/ssh_host_rsa_key.pub ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub
#		/bin/chmod 600 ${HOME}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub
#	fi
#fi


#Initialise Git
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch main
/usr/bin/git config --global pull.rebase false 

#Setup this machine's hostname
. ${HOME}/providerscripts/utilities/housekeeping/InitialiseHostname.sh

#Precautions against kernel panics
/bin/echo "vm.panic_on_oom=1
kernel.panic=10" >> /etc/sysctl.conf

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Changing our preferred SSH port"
/bin/echo "${0} `/bin/date`: Changing to our preferred SSH port" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log



if ( [ "`/bin/grep '^#Port' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^Port' /etc/ssh/sshd_config`" != "" ] )
then
    /bin/sed -i "s/^Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
    /bin/sed -i "s/^#Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
else
    /bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Preventing root logins"
/bin/echo "${0} `/bin/date`: Preventing root logins" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Double down on preventing logins as root. We already tried, but, make absolutely sure because we can't guarantee format of /etc/ssh/sshd_config

#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^AddressFamily.*/AddressFamily inet/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#AddressFamily.*/AddressFamily inet/g' {} +



/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Ensure SSH connections are long lasting"
/bin/echo "${0} `/bin/date`: Ensuring SSH connections are long lasting" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Make sure that client connections to sshd are long lasting
if ( [ "`/bin/grep 'ClientAliveInterval 200' /etc/ssh/sshd_config 2>/dev/null`" = "" ] )
then
    /bin/echo "
ClientAliveInterval 200
ClientAliveCountMax 10" >> /etc/ssh/sshd_config
fi

${HOME}/providerscripts/utilities/processing/RunServiceCommand.sh ssh restart

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} `/bin/date`: Installing necessary software" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#Update and upgrade the software to its latest available versions

${HOME}/installscripts/InstallCoreSoftware.sh

${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'IPMASK' "`${HOME}/providerscripts/utilities/processing/GetIP.sh | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`.%.%"
${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'MYIP' "`${HOME}/providerscripts/utilities/processing/GetIP.sh`" 
${HOME}/providerscripts/utilities/config/StoreConfigValue.sh 'MYPUBLICIP' "`${HOME}/providerscripts/utilities/processing/GetPublicIP.sh`" 

#${HOME}/providerscripts/datastore/EssentialToolsAvailable.sh

${HOME}/security/SetupFirewall.sh

#>&2 /bin/echo "${0} Update.sh"
#${HOME}/installscripts/Update.sh ${BUILDOS}

#>&2 /bin/echo "${0} InstallSoftwareProperties.sh"
#${HOME}/installscripts/InstallSoftwareProperties.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallCurl.sh"
#${HOME}/installscripts/InstallCurl.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallLibSocketSSL.sh"
#${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
#${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallSendEmail.sh"
#${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallSysStat.sh"
#${HOME}/installscripts/InstallSysStat.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallFirewall.sh"
#${HOME}/installscripts/InstallFirewall.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallRsync.sh"
#${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallJQ.sh"
#${HOME}/installscripts/InstallJQ.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallCron.sh"
#${HOME}/installscripts/InstallCron.sh ${BUILDOS}
#>&2 /bin/echo "${0} InstallGo.sh"
#${HOME}/installscripts/InstallGo.sh ${BUILDOS}

#${HOME}/installscripts/InstallMonitoringGear.sh

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Setting timezone"
/bin/echo "${0} `/bin/date`: Setting timezone" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Setup the timezone for this machine

if ( [ "`/usr/bin/timedatectl list-timezones | /bin/grep ${SERVER_TIMEZONE_CONTINENT} | /bin/grep ${SERVER_TIMEZONE_CITY}`" != "" ] )
then
     /usr/bin/timedatectl set-timezone ${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}
    ${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "SERVERTIMEZONECONTINENT" "${SERVER_TIMEZONE_CONTINENT}"
    ${HOME}/providerscripts/utilities/config/StoreConfigValue.sh "SERVERTIMEZONECITY" "${SERVER_TIMEZONE_CITY}"
    export TZ=":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}"
fi

cd ${HOME}

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Setting up datastore tools"
/bin/echo "${0} `/bin/date`: Setting up datastore tools" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

. ${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh
. ${HOME}/providerscripts/datastore/InitialiseAdditionalDatastoreConfigs.sh

#if ( [ ! -d ${HOME}/credentials ] )
#then
#    /bin/mkdir -p ${HOME}/credentials
#    /bin/chmod 700 ${HOME}/credentials
#fi    
#if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/db_cred"`" = "1" ] )
#then
#    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/db_cred ${HOME}/credentials/db_cred
#    if ( [ -f ${HOME}/credentials/db_cred ] )
#    then
#        /bin/touch ${HOME}/runtime/CREDENTIALS_PRIMED
#    fi
#else
#    /bin/echo "${0} `/bin/date`: Failed to get database credentials from the datastore" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#fi


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Getting infrastructure repositories from git"
/bin/echo "${0} `/bin/date`: Getting infrastructure repositories from git" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

cd ${HOME}

#Stop cron from sending notification emails
/bin/echo "MAILTO=''" > /var/spool/cron/crontabs/root

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installing the application DB"
/bin/echo "${0} `/bin/date`: Installing the application DB" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

/bin/echo "" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} ####################APPLICATION INSTALLATION LOG STREAM BEGIN##########################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Initialise the database
#. ${HOME}/providerscripts/database/singledb/InstallSingleDB.sh ${DATABASE_INSTALLATION_TYPE}
 
notification_file="${HOME}/runtime/DATABASE_SERVER_INSTALLED"
if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	notification_file="${HOME}/runtime/DATABASE_CLIENT_INSTALLED"
fi
  	/bin/echo "${0} `/bin/date`: 1" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#We want to be sure that the database server is installed
count="0"
while ( [ ! -f ${notification_file} ] && [ "${count}" -lt "60" ] )
do
	/bin/echo "${0} WAITING FOR NOTIFICATION FILE" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
	/bin/sleep 2
 	count="`/usr/bin/expr ${count} + 1`"
done
/bin/echo "${0} `/bin/date`: 2" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

if ( [ "${count}" = "60" ] )
then
	#Sometimes the database server doesn't install when apt-fast is used so if this is the case it will reach 60 and we give it another go
 	#If it still doesn't install then the whole build will fail and will be reinitiated
  	if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
   	then
    		${HOME}/installscripts/InstallDatabaseClient.sh ${BUILDOS} 
      	else
		${HOME}/installscripts/InstallDatabaseServer.sh ${BUILDOS} 
  	fi
fi

/bin/echo "${0} `/bin/date`: 3" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

${HOME}/providerscripts/database/InitialiseDatabase.sh

BYPASS_DB_LAYER="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BYPASSDBLAYER'`"

if ( [ "${BYPASS_DB_LAYER}" != "1" ] )
then
    #...and install the application
    if ( [ "${BASELINE_DB_REPOSITORY_NAME}" != "VIRGIN" ] )
    then    
    /bin/echo "${0} `/bin/date`: 4" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

        if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh BUILDARCHIVECHOICE:baseline`" = "1" ] )
        then
		${HOME}/applicationdb/InstallApplicationDB.sh 
  /bin/echo "${0} `/bin/date`: 5" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

            	. ${HOME}/providerscripts/application/CustomiseApplication.sh
	       /bin/echo "${0} `/bin/date`: 6" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

        else
        	${HOME}/applicationdb/InstallApplicationDB.sh 
    	fi
    fi
fi

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} ################APPLICATION INSTALLATION LOG STREAM END################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Installation of  the application DB is complete"


/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Configure our SSH settings"
/bin/echo "${0} `/bin/date`: Configuring our SSH settings" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log


#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#>&2 /bin/echo "${0} Disabling password authenticator"
#/bin/echo "${0} `/bin/date`: Disabling password authentication" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#/bin/sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#/bin/sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#>&2 /bin/echo "${0} Changing our preferred SSH port"
#/bin/echo "${0} `/bin/date`: Changing to our preferred SSH port" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log##
#
##
#
#if ( [ "`/bin/grep '^#Port' /etc/ssh/sshd_config`" != "" ] || [ "`/bin/grep '^Port' /etc/ssh/sshd_config`" != "" ] )
#then
#    /bin/sed -i "s/^Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
#    /bin/sed -i "s/^#Port.*/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
#else
#    /bin/echo "PermitRootLogin no" >> /etc/ssh/sshd_config
#fi

#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#>&2 /bin/echo "${0} Preventing root logins"
#/bin/echo "${0} `/bin/date`: Preventing root logins" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Double down on preventing logins as root. We already tried, but, make absolutely sure because we can't guarantee format of /etc/ssh/sshd_config

#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^AddressFamily.*/AddressFamily inet/g' {} +
#/usr/bin/find /etc/ssh -name '*' -type f -exec sed -i 's/^#AddressFamily.*/AddressFamily inet/g' {} +



#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#>&2 /bin/echo "${0} Ensure SSH connections are long lasting"
#/bin/echo "${0} `/bin/date`: Ensuring SSH connections are long lasting" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
#/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log

#Make sure that client connections to sshd are long lasting
#if ( [ "`/bin/grep 'ClientAliveInterval 200' /etc/ssh/sshd_config 2>/dev/null`" = "" ] )
#then
#    /bin/echo "
#ClientAliveInterval 200
#ClientAliveCountMax 10" >> /etc/ssh/sshd_config
#fi

#${HOME}/providerscripts/utilities/RunServiceCommand.sh ssh restart

#Set userallow for fuse
/bin/sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf
SERVER_USER_PASSWORD="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"

/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
>&2 /bin/echo "${0} Initialise Cron"
/bin/echo "${0} `/bin/date`: Initialising cron" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
/bin/echo "${0} #######################################################################################" >> ${HOME}/logs/initialbuild/BUILD_PROCESS_MONITORING.log
# Configure the crontab
. ${HOME}/cron/InitialiseCron.sh

/bin/chown -R ${SERVER_USER}:${SERVER_USER} ${HOME}

${HOME}/providerscripts/utilities/processing/UpdateIPs.sh

${HOME}/providerscripts/utilities/housekeeping/CleanupAfterBuild.sh

${HOME}/providerscripts/email/SendEmail.sh "A DATABASE HAS BEEN SUCCESSFULLY BUILT" "A Database has been successfully built and primed as is rebooting ready for use" "INFO"

/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
/usr/bin/touch ${HOME}/runtime/DATABASE_READY

${HOME}/providerscripts/utilities/security/EnforcePermissions.sh

${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &

#/usr/sbin/shutdown -r now

