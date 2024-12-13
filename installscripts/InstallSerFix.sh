#!/bin/sh
###################################################################################
# Description: Fixes wordpress serialisation issue
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

if ( [ "${buildos}" = "ubuntu" ] )
then
    if ( [ ! -d /root/scratch ] )
    then
        /bin/mkdir /root/scratch
    fi
    
    tarball_url="`/usr/bin/curl -L https://api.github.com/repos/astockwell/serfix/releases/latest | /usr/bin/jq -r '.tarball_url'`"
    /usr/bin/wget -c ${tarball_url} -O- | /usr/bin/tar -xz -C /root/scratch
    cwd="`/usr/bin/pwd`"
    cd /root/scratch/astock*
    /usr/bin/go build serfix.go
    /bin/mv serfix /usr/local/bin
    /bin/chmod 755 /usr/local/bin/serfix
    /bin/rm -r /root/scratch
    cd ${cwd}
fi

if ( [ "${buildos}" = "debian" ] )
then
    if ( [ ! -d /root/scratch ] )
    then
        /bin/mkdir /root/scratch
    fi
    
    tarball_url="`/usr/bin/curl -L https://api.github.com/repos/astockwell/serfix/releases/latest | /usr/bin/jq -r '.tarball_url'`"
    /usr/bin/wget -c ${tarball_url} -O- | /usr/bin/tar -xz -C /root/scratch
    cwd="`/usr/bin/pwd`"
    cd /root/scratch/astock*
    /usr/bin/go build serfix.go
    /bin/mv serfix /usr/local/bin
    /bin/chmod 755 /usr/local/bin/serfix
    /bin/rm -r /root/scratch
    cd ${cwd}
fi
/bin/touch ${HOME}/runtime/installedsoftware/InstallSerFix.sh


