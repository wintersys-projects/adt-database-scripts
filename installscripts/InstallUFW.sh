#!/bin/sh
###################################################################################
# Description: This  will install ufw
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

HOME="`/bin/cat /home/homedir.dat`"
apt=""
if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
    apt="/usr/bin/apt-get"
elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
    apt="/usr/sbin/apt-fast"
fi

export DEBIAN_FRONTEND=noninteractive
install_command="${apt} -o DPkg::Lock::Timeout=-1 -o Dpkg::Use-Pty=0 -qq -y install " 

if ( [ "${apt}" != "" ] )
then
    if ( [ "${BUILDOS}" = "ubuntu" ] )
    then
        eval ${install_command} ufw        
    fi

    if ( [ "${BUILDOS}" = "debian" ] )
    then
        eval ${install_command} ufw        
    fi
fi

/usr/sbin/ufw disable

if ( [ ! -f /usr/bin/ufw ] )
then
    /usr/bin/ln -s /usr/sbin/ufw /usr/bin/ufw
fi

