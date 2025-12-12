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
	BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"
else 
	BUILDOS="${buildos}"
fi

BUILDOS_VERSION="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOSVERSION'`"


apt=""
if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-get" ] )
then
	apt="/usr/bin/apt-get"
fi

export DEBIAN_FRONTEND=noninteractive
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

count="0"
while ( [ ! -f /usr/bin/mysqld_safe ] && [ "${count}" -lt "5" ] )
do
	if ( [ "${apt}" != "" ] )
	then
		if ( [ "${BUILDOS}" = "ubuntu" ] )
		then
			minor_version="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "MYSQL" | /usr/bin/awk -F':' '{print $NF}'`"
			major_version="`/bin/echo ${minor_version} | /usr/bin/cut -d '.' -f 1,2`"
			/usr/bin/wget https://dev.mysql.com/get/downloads/mysql-${major_version}/mysql-server_${minor_version}-1ubuntu${BUILDOS_VERSION}_amd64.deb-bundle.tar		
			/usr/bin/tar -xvf ./mysql-server_${minor_version}-1ubuntu${BUILDOS_VERSION}_amd64.deb-bundle.tar -C /opt
  			/bin/rm ./mysql-server_${minor_version}-1ubuntu${BUILDOS_VERSION}_amd64.deb-bundle.tar
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
  			/bin/rm /opt/*mysql*
		fi

		if ( [ "${BUILDOS}" = "debian" ] )
		then
			minor_version="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "MYSQL" | /usr/bin/awk -F':' '{print $NF}'`"
        	major_version="`/bin/echo ${minor_version} | /usr/bin/cut -d '.' -f 1,2`"

			if ( [ "${BUILDOS_VERSION}" = "13" ] )
			then
  				#workaround until there's versions released of mysql with trixie support when there is comment this and uncomment the below
    			/usr/bin/wget https://deb.debian.org/debian/pool/main/liba/libaio/libaio1_0.3.113-4_amd64.deb -O /opt/libaio1_0.3.113-4_amd64.deb
				${install_command} /opt/libaio1_0.3.113-4_amd64.deb
				#${install_command} libaio-dev libaio1t64
   			elif ( [ "${BUILDOS_VERSION}" = "12" ] )
	 		then
				${install_command} libaio1
   			fi

        	/usr/bin/wget https://dev.mysql.com/get/downloads/mysql-${major_version}/mysql-server_${minor_version}-1debian${BUILDOS_VERSION}_amd64.deb-bundle.tar

        	if ( [ "$?" != "0" ] )
        	then
        		if ( [ "${BUILDOS_VERSION}" = "13" ] )
            	then
            		BUILDOS_VERSION="12"
                	/usr/bin/wget https://dev.mysql.com/get/downloads/mysql-${major_version}/mysql-server_${minor_version}-1debian${BUILDOS_VERSION}_amd64.deb-bundle.tar
            	fi
        	fi

        	/usr/bin/tar -xvf ./mysql-server_${minor_version}-1debian${BUILDOS_VERSION}_amd64.deb-bundle.tar -C /opt
        	/bin/rm ./mysql-server_${minor_version}-1debian${BUILDOS_VERSION}_amd64.deb-bundle.tar
	 		${install_command} libmecab2 libnuma1 psmisc 
			DEBIAN_FRONTEND=noninteractive /usr/sbin/dpkg-preconfigure /opt/mysql-community-server_*.deb
			/usr/bin/dpkg -i /opt/mysql-common_*.deb
        	/usr/bin/dpkg -i /opt/mysql-community-client-plugins_*.deb
        	/usr/bin/dpkg -i /opt/mysql-community-client-core_*.deb
        	/usr/bin/dpkg -i /opt/mysql-community-client_*.deb
        	/usr/bin/dpkg -i /opt/mysql-client_*.deb
        	/usr/bin/dpkg -i /opt/mysql-community-server-core_*.deb
        	/usr/bin/dpkg -i /opt/mysql-community-server_*.deb
        	/usr/bin/dpkg -i /opt/mysql-server_*.deb
        	/bin/rm /opt/*mysql*
    	fi
	fi
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ ! -f /usr/bin/mysqld_safe ] && [ "${count}" = "5" ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR MYSQL" "I believe that mysql server hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallMySQLServer.sh				
fi
