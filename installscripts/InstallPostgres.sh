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
        postgres_version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-common                          #####UBUNTU-POSTGRESQL-REPO#####
        /usr/bin/yes | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh                                                    #####UBUNTU-POSTGRESQL-REPO#####
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-${postgres_version}            #####UBUNTU-POSTGRESQL-REPO#####
        /usr/bin/sudo -su postgres /usr/lib/postgresql/${postgres_version}/bin/postgres -D /var/lib/postgresql/${postgres_version}/main -c config_file=/etc/postgresql/${postgres_version}/main/postgresql.conf    #####UBUNTU-POSTGRESQL-REPO#####
        ${HOME}/providerscripts/utilities/RunServiceCommand.sh postgresql restart                                                   
    fi
  
    if ( [ "${buildos}" = "debian" ] && [ ! -f /usr/lib/postgresql ] )
    then   
        postgres_version="`${HOME}/providerscripts/utilities/ExtractBuildStyleValues.sh "POSTGRES" | /usr/bin/awk -F':' '{print $NF}'`"
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-common                            #####DEBIAN-POSTGRESQL-REPO#####
        /usr/bin/yes | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh                                                        #####DEBIAN-POSTGRESQL-REPO#####
        DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install postgresql-${postgres_version}                        #####DEBIAN-POSTGRESQL-REPO#####
        /usr/bin/sudo -su postgres /usr/lib/postgresql/${postgres_version}/bin/postgres -D /var/lib/postgresql/${postgres_version}/main -c config_file=/etc/postgresql/${postgres_version}/main/postgresql.conf    #####DEBIAN-POSTGRESQL-REPO#####
        ${HOME}/providerscripts/utilities/RunServiceCommand.sh postgresql restart
    fi
	/bin/touch ${HOME}/runtime/installedsoftware/InstallPostgres.sh
fi

