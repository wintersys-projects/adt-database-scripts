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

if ( [ "${buildos}" = "" ] )
then
	BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
	BUILDOS="${buildos}"
fi

apt=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

export DEBIAN_FRONTEND=noninteractive
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

if ( [ "${apt}" != "" ] )
then
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
 		cwd="`/usr/bin/pwd`"
		cd /opt
		/usr/bin/wget https://dev.mysql.com/get/downloads/mysql-8.4/mysql-server_8.4.5-1ubuntu24.04_amd64.deb-bundle.tar
		/usr/bin/tar -xvf ./mysql-server_8.4.5-1ubuntu24.04_amd64.deb-bundle.tar
  		${install_command} libmecab2
		DEBIAN_FRONTEND=noninteractive /usr/sbin/dpkg-preconfigure ./mysql-community-server_*.deb
		/usr/bin/dpkg -i /opt/mysql-common_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-client-plugins_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-client-core_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-client_*.deb
		/usr/bin/dpkg -i /opt/mysql-client_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-server-core_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-server_*.deb
		/usr/bin/dpkg -i /opt/mysql-server_*.deb		
  		cd ${cwd}
		/bin/rm /opt/*mysql*
 	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
  		cwd="`/usr/bin/pwd`"
		cd /opt
		/usr/bin/wget https://dev.mysql.com/get/downloads/mysql-8.4/mysql-server_8.4.5-1debian12_amd64.deb-bundle.tar
		/usr/bin/tar -xvf ./mysql-server_8.4.5-1debian12_amd64.deb-bundle.tar
  		${install_command} libmecab2
		DEBIAN_FRONTEND=noninteractive /usr/sbin/dpkg-preconfigure ./mysql-community-server_*.deb
		/usr/bin/dpkg -i /opt/mysql-common_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-client-plugins_*.deb
  		/usr/bin/dpkg -i /opt/mysql-community-client-core_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-client_*.deb
		/usr/bin/dpkg -i /opt/mysql-client_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-server-core_*.deb
		/usr/bin/dpkg -i /opt/mysql-community-server_*.deb
		/usr/bin/dpkg -i /opt/mysql-server_*.deb	
  		cd ${cwd}
		/bin/rm /opt/*mysql*
 	fi
	/bin/touch ${HOME}/runtime/installedsoftware/InstallMySQLServer.sh
fi
