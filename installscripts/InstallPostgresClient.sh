#!/bin/sh
###################################################################################
# Description: This  will install postgres server
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

apt=""
if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

export DEBIAN_FRONTEND=noninteractive
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 

if ( [ "${apt}" != "" ] )
then
	#For postgres if it is already installed on the OS we default to the installed version otherwise we install the user's requested version
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then    
		if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`" != "cloud-init" ] )
		then
			postgres_version="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
			${install_command} postgresql-common
			/bin/echo "yes" | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
			${install_command} curl ca-certificates
			/usr/bin/install -d /usr/share/postgresql-common/pgdg
			/usr/bin/curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
			. /etc/os-release
			#    /bin/sh -c '/bin/echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
			${update_command}
			${install_command} postgresql-client-${postgres_version}                          
		fi
	fi

	if ( [ "${BUILDOS}" = "debian" ] && [ ! -f /usr/lib/postgresql ] )
	then  
		if ( [ "`${HOME}/utilities/config/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`" != "cloud-init" ] )
		then
			postgres_version="`${HOME}/utilities/config/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
			${install_command} postgresql-common
			/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
			${install_command} curl ca-certificates
			/usr/bin/install -d /usr/share/postgresql-common/pgdg
			/usr/bin/curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
			. /etc/os-release
			/bin/sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
			${update_command}
			${install_command} postgresql-client-${postgres_version}
		fi
	fi
fi

if ( [ ! -f /usr/bin/psql ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR POSTGRES" "I believe that postgres client hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallPostgresClient.sh
fi

