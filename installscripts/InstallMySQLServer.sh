#!/bin/sh
###################################################################################
# Description: This  will install the mysql server. I considered it to be too lengthy a process
# to build mysql server from source, build time wise, so, only the repo option is supported.
# Date: 18/11/2016
# Author : Peter Winter
###################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ "${1}" != "" ] )
then
    buildos="${1}"
fi

if ( [ "${BUILDOS}" = "" ] )
then
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
else
    BUILDOS="${buildos}"
fi

BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"

apt=""
if ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
    apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
    apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
    if ( [ "${buildos}" = "ubuntu" ] )
	then
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install gnupg    #####UBUNTU-MYSQLCLIENT-REPO#####
 		mysql_apt_config="`/usr/bin/wget -O- -q https://dev.mysql.com/downloads/repo/apt/ | grep mysql-apt-config | grep -o '([^)]*)' | /bin/sed -e 's/(//' -e 's/)//'`"	#####UBUNTU-MYSQLCLIENT-REPO#####
		/usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} && DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i ${mysql_apt_config}	#####UBUNTU-MYSQLCLIENT-REPO-SKIP#####
		/bin/rm ${mysql_apt_config}									#####UBUNTU-MYSQLCLIENT-REPO-SKIP#####
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages #####UBUNTU-MYSQLCLIENT-REPO#####
		DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60 -qq -y install mysql-server	#####UBUNTU-MYSQLCLIENT-REPO#####
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install gnupg    #####DEBIAN-MYSQLCLIENT-REPO#####
 		mysql_apt_config="`/usr/bin/wget -O- -q https://dev.mysql.com/downloads/repo/apt/ | grep mysql-apt-config | grep -o '([^)]*)' | /bin/sed -e 's/(//' -e 's/)//'`"	#####DEBIAN-MYSQLCLIENT-REPO#####
		/usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} && DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i ${mysql_apt_config} #####DEBIAN-MYSQLCLIENT-REPO-SKIP#####
		/bin/rm ${mysql_apt_config}									#####DEBIAN-MYSQLCLIENT-REPO-SKIP#####
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages #####DEBIAN-MYSQLCLIENT-REPO#####
		DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60 -qq -y install mysql-server	#####DEBIAN-MYSQLCLIENT-REPO#####
	fi
	/bin/touch ${HOME}/runtime/installedsoftware/InstallMySQLServer.sh
fi
