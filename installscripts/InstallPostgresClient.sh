#!/bin/sh
###################################################################################
# Description: This  will install postgres client
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
    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | /usr/bin/sudo /usr/bin/tee /etc/apt/trusted.gpg.d/myrepo.asc
        /bin/echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | /usr/bin/sudo /usr/bin/tee /etc/apt/sources.list.d/pgdg.list
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -y -qq install postgresql-client-`/bin/echo ${version} | /usr/bin/awk -F'.' '{print $1}'`
    fi

    if ( [ "${BUILDOS}" = "debian" ] )
    then
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
        /usr/bin/wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | /usr/bin/sudo /usr/bin/tee /etc/apt/trusted.gpg.d/myrepo.asc
        /bin/echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | /usr/bin/sudo /usr/bin/tee /etc/apt/sources.list.d/pgdg.list
        ${HOME}/installscripts/Update.sh ${BUILDOS}
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -y -qq install postgresql-client-`/bin/echo ${version} | /usr/bin/awk -F'.' '{print $1}'`
    fi
fi

