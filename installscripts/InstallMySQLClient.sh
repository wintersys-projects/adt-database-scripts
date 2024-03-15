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

if ( [ "${BUILDOS}" = "" ] )
then
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
else
    BUILDOS="${buildos}"
fi

BUILDOSVERSION="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOSVERSION'`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"

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
    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install gnupg
        mysql_apt_config="`/usr/bin/wget -O- https://dev.mysql.com/downloads/repo/apt/ | /bin/grep -o mysql-apt-config.* | /usr/bin/head -1 | /bin/sed 's/deb.*/deb/g'`"
        /usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} 
        DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i ${mysql_apt_config}
        /bin/rm ${mysql_apt_config}
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=69 -qq -y install mysql-client
    fi

    if ( [ "${BUILDOS}" = "debian" ] )
    then
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install gnupg
        mysql_apt_config="`/usr/bin/wget -O- https://dev.mysql.com/downloads/repo/apt/ | /bin/grep -o mysql-apt-config.* | /usr/bin/head -1 | /bin/sed 's/deb.*/deb/g'`"
        /usr/bin/wget https://dev.mysql.com/get/${mysql_apt_config} 
        DEBIAN_FRONTEND=noninteractive /usr/bin/dpkg -i ${mysql_apt_config}
        /bin/rm ${mysql_apt_config}
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60 -qq -y install mysql-client
    fi
fi
