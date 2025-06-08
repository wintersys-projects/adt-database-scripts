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
set -x

#Get ourselves orientated so that we know where our home is
USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
/bin/echo 'export HOME="/home/'${USER_HOME}'"' >> /home/${USER_HOME}/.bashrc
/bin/chmod 644 /home/${USER_HOME}/.bashrc
/bin/chown ${USER_HOME}:root /home/${USER_HOME}/.bashrc

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

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

/bin/mv ${HOME}/utilities/security/Super.sh ${HOME}/super
/bin/chmod 400 ${HOME}/super/Super.sh

out_file="initialbuild/database-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/database-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}

/bin/echo "${0} Initialising Datastore"
${HOME}/providerscripts/datastore/InitialiseDatastoreConfig.sh
${HOME}/providerscripts/datastore/InitialiseAdditionalDatastoreConfigs.sh

MYSQL_USER="mysql"
MYSQL_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
/usr/sbin/adduser --disabled-password --gecos "" ${MYSQL_USER}
/bin/echo ${MYSQL_USER}:${MYSQL_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd

/bin/echo "${0} Installing Database"
${HOME}/installscripts/InstallDatabase.sh

BASELINE_DB_REPOSITORY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"

/bin/echo "${0} Initialising Database"
${HOME}/providerscripts/database/InitialiseDatabase.sh

BYPASS_DB_LAYER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BYPASSDBLAYER'`"

if ( [ -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] )
then
	/bin/rm ${HOME}/runtime/DB_APPLICATION_INSTALLED
fi

if ( [ "${BYPASS_DB_LAYER}" != "1" ] )
then
	#...and install the application
	if ( [ "${BASELINE_DB_REPOSITORY_NAME}" != "VIRGIN" ] )
	then    
		/bin/echo "${0} Installing bespoke application"
		${HOME}/application/db/InstallApplicationDB.sh 
	fi
fi

details=""
for directory in `/bin/ls /home | /bin/grep "X*X"`
do
        details="${details} ${directory}:`/usr/bin/stat -c %Y /home/${directory}`"
done
youngest_record_age="0"
for record in ${details}
do
        age="`/bin/echo ${record} | /usr/bin/awk -F':' '{print $2}'`"
        if ( [ ${age} -gt ${youngest_record_age} ] )
        then
                youngest_record_age="${age}"
                youngest_record="`/bin/echo ${record} | /usr/bin/awk -F':' '{print $1}'`"
        fi
done

for directory in `/bin/ls /home | /bin/grep "X*X"`
do
        if ( [ "${directory}" != "${youngest_record}" ] )
        then
                /bin/echo "deleting ${directory}" > /home/DELETE
        fi
done




