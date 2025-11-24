#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : This script is the main script for building a database server. It is called by "cloud-init" when
# a new database server is built
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
/bin/echo 'export HOME="/home/'${USER_HOME}'"' >> /home/${USER_HOME}/.bashrc
/bin/chmod 644 /home/${USER_HOME}/.bashrc
/bin/chown ${USER_HOME}:root /home/${USER_HOME}/.bashrc

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

#comment/amend as you desire
if ( [ ! -f /root/.vimrc-adt ] )
then
        /bin/echo "
		color elflord
        set mouse=r
        syntax on
        filetype indent on
        set smartindent
        set fo-=or
        autocmd BufRead,BufWritePre *.sh normal gg=G " > /root/.vimrc-adt

        /bin/echo "alias vim='/usr/bin/vim -u /root/.vimrc-adt'" >> /root/.bashrc
        /bin/echo "alias vi='/usr/bin/vim -u /root/.vimrc-adt'" >> /root/.bashrc
fi

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


SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

/bin/mv ${HOME}/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

out_file="initialbuild/database-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/database-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}


BASELINE_DB_REPOSITORY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"
GIT_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'GITUSER' | /bin/sed 's/#/ /g'`"
GIT_EMAIL_ADDRESS="`${HOME}/utilities/config/ExtractConfigValue.sh 'GITEMAILADDRESS'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"
PRIMARY_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'PRIMARYREGION'`"
BYPASS_DB_LAYER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BYPASSDBLAYER'`"

#Initialise Git
/usr/bin/git config --global user.name "${GIT_USER}"
/usr/bin/git config --global user.email ${GIT_EMAIL_ADDRESS}
/usr/bin/git config --global init.defaultBranch main
/usr/bin/git config --global pull.rebase false 

if ( [ -f ${HOME}/utilities/software/PushInfrastructureScriptsUpdates.sh ] )
then
	/bin/cp ${HOME}/utilities/software/PushInfrastructureScriptsUpdates.sh /usr/sbin/push
	/bin/chmod 755 /usr/sbin/push
	/bin/chown root:root /usr/sbin/push
fi
if ( [ -f ${HOME}/utilities/software/PushAndSyncInfrastructureScriptsUpdates.sh ] )
then
	/bin/cp ${HOME}/utilities/software/PushAndSyncInfrastructureScriptsUpdates.sh /usr/sbin/push-and-sync
	/bin/chmod 755 /usr/sbin/push-and-sync
	/bin/chown root:root /usr/sbin/push-and-sync
fi
if ( [ -f ${HOME}/utilities/software/SyncInfrastructureScriptsUpdates.sh ] )
then
	/bin/cp ${HOME}/utilities/software/SyncInfrastructureScriptsUpdates.sh /usr/sbin/sync
	/bin/chmod 755 /usr/sbin/sync
	/bin/chown root:root /usr/sbin/sync
fi


${HOME}/utilities/config/StoreConfigValue.sh 'IPMASK' "`${HOME}/utilities/processing/GetIP.sh | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`.%.%"
${HOME}/utilities/config/StoreConfigValue.sh 'MYIP' "`${HOME}/utilities/processing/GetIP.sh`" 
${HOME}/utilities/config/StoreConfigValue.sh 'MYPUBLICIP' "`${HOME}/utilities/processing/GetPublicIP.sh`" 

/bin/echo "${0} Setting up firewall"
${HOME}/security/SetupFirewall.sh

cd ${HOME}


/bin/echo "${0} Initialising Datastore"
${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh

cd ${HOME}

count="0"
while ( [ ! -f ${HOME}/runtime/DATABASE_SYSTEM_INSTALLED ] && [ "${count}" -lt "71" ] )
do
	/bin/sleep 2
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ "${count}" = "71" ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "A DATABASE DID NOT INSTALL" "The database server ran out of time to install" "ERROR"
fi

if ( ( [ "${MULTI_REGION}" = "0" ] || ( [ "${MULTI_REGION}" = "1" ] && [ "${PRIMARY_REGION}" = "1" ] ) ) ||  [ "${BYPASS_DB_LAYER}" != "1" ] )
then
	/bin/echo "${0} Initialising Database"
	${HOME}/providerscripts/database/InitialiseDatabase.sh

	#...and install the application
	if ( [ "${BASELINE_DB_REPOSITORY_NAME}" != "VIRGIN" ] )
	then    
		/bin/echo "${0} Installing bespoke application"
		${HOME}/application/db/InstallApplicationDB.sh 
	fi
elif ( [ "${MULTI_REGION}" = "1" ] && [ "${PRIMARY_REGION}" = "0" ] )
then
	${HOME}/providerscripts/database/dbaas/AdjustCredentialsForRegion.sh
fi

# Configure the crontab
${HOME}/cron/InitialiseCron.sh

${HOME}/utilities/processing/UpdateIPs.sh
${HOME}/utilities/housekeeping/CleanupAfterBuild.sh
${HOME}/providerscripts/email/SendEmail.sh "A DATABASE HAS BEEN SUCCESSFULLY BUILT" "A Database has been successfully built and primed as is rebooting ready for use" "INFO"
/bin/touch ${HOME}/runtime/DONT_MESS_WITH_THESE_FILES-SYSTEM_BREAK
/usr/bin/touch ${HOME}/runtime/DATABASE_READY

${HOME}/utilities/security/EnforcePermissions.sh

#/bin/echo "${0} Updating Software"
#${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &

