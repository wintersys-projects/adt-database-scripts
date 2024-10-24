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
    #For postgres if it is already installed on the OS we default to the installed version otherwise we install the user's requested version
    if ( [ "${buildos}" = "ubuntu" ] )
    then    
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-common
        /usr/bin/yes | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-${version}
        /usr/bin/sudo -su postgres /usr/lib/postgresql/${version}/bin/postgres -D /var/lib/postgresql/${version}/main -c config_file=/etc/postgresql/${version}/main/postgresql.conf
        /usr/sbin/service postgresql restart
    fi
  
    if ( [ "${buildos}" = "debian" ] && [ ! -f /usr/lib/postgresql ] )
    then   
        version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-common
        /usr/bin/yes | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-${version}
        /usr/bin/sudo -su postgres /usr/lib/postgresql/${version}/bin/postgres -D /var/lib/postgresql/${version}/main -c config_file=/etc/postgresql/${version}/main/postgresql.conf
        /usr/sbin/service postgresql restart
    fi
fi

