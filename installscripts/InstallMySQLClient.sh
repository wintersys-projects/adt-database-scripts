#!/bin/sh
###################################################################################
# Description: This  will install the mysql client
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
update_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y update " 
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

if ( [ "${apt}" != "" ] )
then
	if ( [ "${BUILDOS}" = "ubuntu" ] )
	then
		eval ${install_command} gnupg    
		mysql_apt_config="`/usr/bin/wget -O- -q https://dev.mysql.com/downloads/repo/apt/ | grep mysql-apt-config | grep -o '([^)]*)' | /bin/sed -e 's/(//' -e 's/)//'`"	
		/usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} && /usr/bin/dpkg -i ${mysql_apt_config}	
		/bin/rm ${mysql_apt_config}									
		eval ${update_command} --allow-change-held-packages 
		eval ${install_command} mysql-client	
	fi

	if ( [ "${BUILDOS}" = "debian" ] )
	then
		eval ${install_command} gnupg 
		mysql_apt_config="`/usr/bin/wget -O- -q https://dev.mysql.com/downloads/repo/apt/ | grep mysql-apt-config | grep -o '([^)]*)' | /bin/sed -e 's/(//' -e 's/)//'`"	
		/usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} && /usr/bin/dpkg -i ${mysql_apt_config} 
		/bin/rm ${mysql_apt_config}									
		eval ${update_command} --allow-change-held-packages 
		eval ${install_command} mysql-client	
	fi
fi

if ( [ ! -f /usr/bin/mysql ] )
then
	${HOME}/providerscripts/email/SendEmail.sh "INSTALLATION ERROR MYSQL" "I believe that mysql-client hasn't installed correctly, please investigate" "ERROR"
else
	/bin/touch ${HOME}/runtime/installedsoftware/InstallMySQLClient.sh				
fi
