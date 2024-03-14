#!/bin/sh
####################################################################################
# Author: Peter Winter
# Date :  24/02/2022
# Description: This will list a particular value from the configuration datastore
#######################################################################################
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
######################################################################################
######################################################################################
#set -x

export HOME=`/bin/cat /home/homedir.dat`
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
configbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"
count="0"
file="`/bin/echo ${1} | /usr/bin/awk -F'/' '{print $NF}'`" 

if ( [ "`${HOME}/providerscripts/utilities/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
then
   /usr/bin/s3cmd --force get s3://${configbucket}/$1 /tmp 1>/dev/null

   while ( [ ! -f /tmp/${file} ] && [ "${count}" -lt "10" ] )
   do
       /bin/sleep 2
       count="`/usr/bin/expr ${count} + 1`"
       /usr/bin/s3cmd --force get s3://${configbucket}/$1 /tmp 1>/dev/null
   done
fi

if ( [ "$2" = "1" ] )
then
    /bin/sed '1q;d' /tmp/${file}
fi
if ( [ "$2" = "2" ] )
then
    /bin/sed '2q;d' /tmp/${file}
fi
if ( [ "$2" = "3" ] )
then
    /bin/sed '3q;d' /tmp/${file}
fi

/bin/rm /tmp/${file}
