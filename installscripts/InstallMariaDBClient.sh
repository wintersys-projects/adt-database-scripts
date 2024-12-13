#!/bin/sh
###################################################################################
# Description: This  will install mariadb server. I considered it to be too lengthy a process
# to build mariadb from source, build time wise, so, only the repo option is supported.
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
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"
else
    BUILDOS="${buildos}"
fi

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
        mariadb_version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "MARIADB" | /usr/bin/awk -F':' '{print $NF}'`"                         
        /usr/bin/curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${mariadb_version}"    #####UBUNTU-MARIACLIENT-REPO#####
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60  -qq -y install mariadb-client                                                 #####UBUNTU-MARIACLIENT-REPO#####
    fi

    if ( [ "${BUILDOS}" = "debian" ] )
    then
        mariadb_version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "MARIADB" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${mariadb_version}"    #####DEBIAN-MARIACLIENT-REPO#####
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=60  -qq -y install mariadb-client                                                         #####DEBIAN-MARIACLIENT-REPO#####
    fi
    /bin/touch ${HOME}/runtime/installedsoftware/InstallMariaDBClient.sh				
fi
