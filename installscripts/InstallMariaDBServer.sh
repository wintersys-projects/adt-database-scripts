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

if ( [ "${BUILDOS}" = "" ] )
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
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "MARIADB" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${version}"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install mariadb-server 

        /bin/sed -i 's/^character-set-server.*/character-set-server     = utf8mb4/g' /etc/mysql/mariadb.conf.d/50-server.cnf
        /bin/sed -i 's/^character-set-collations.*/character-set-collations     = utf8mb4/g' /etc/mysql/mariadb.conf.d/50-server.cnf
    
        /usr/bin/systemctl start mariadb
        /usr/bin/systemctl enable mariadb
    fi

    if ( [ "${BUILDOS}" = "debian" ] )
    then
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "MARIADB" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${version}"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1  -qq -y install mariadb-server

        /bin/sed -i 's/^character-set-server.*/character-set-server     = utf8mb4/g' /etc/mysql/mariadb.conf.d/50-server.cnf
        /bin/sed -i 's/^character-set-collations.*/character-set-collations     = utf8mb4/g' /etc/mysql/mariadb.conf.d/50-server.cnf
    
        /usr/bin/systemctl start mariadb
        /usr/bin/systemctl enable mariadb
    fi
fi
