#!/bin/sh
####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This script will configure the datastore tool for multiple regions
# which can be used by the backup scripts to make multi-region resilient backups
# each time a backup process runs. 
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

export HOME="`/bin/cat /home/homedir.dat`"
SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
S3_HOST_BASE="`${HOME}/utilities/config/ExtractConfigValue.sh 'S3HOSTBASE' | /usr/bin/awk -F':' '{print $1}'`"
datastore_regions="`${HOME}/utilities/config/ExtractConfigValues.sh 'S3HOSTBASE' 'stripped' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g' | /bin/sed 's/config//g'`"

if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
then
	count="0"
	if ( [ -f ${HOME}/.s3cfg ] )
	then
		for datastore_region in ${datastore_regions}
		do
			if ( [ "${count}" != "0" ] )
			then
				/bin/cp  ${HOME}/.s3cfg  ${HOME}/.s3cfg-${count}
				/bin/sed -i "s/${primary_datastore_region}/${datastore_region}/" ${HOME}/.s3cfg-${count}
				/bin/chown ${SERVER_USER}:${SERVER_USER} ${HOME}/.s3cfg-${count}
			elif ( [ "${count}" = "0" ] )
			then
				primary_datastore_region="${datastore_region}"
			fi
			count="`/usr/bin/expr ${count} + 1`"
		done
	fi
fi

if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTORETOOL:s5cmd'`" = "1" ] )
then
	count="0"
	if ( [ -f ${HOME}/.s5cfg ] )
	then
		for datastore_region in ${datastore_regions}
		do
			if ( [ "${count}" != "0" ] )
			then
				/bin/cp  ${HOME}/.s5cfg  ${HOME}/.s5cfg-${count}
				/bin/echo "host_base = ${datastore_region}" >> ${HOME}/.s5cfg-${count}
				/bin/chown ${SERVER_USER}:${SERVER_USER} ${HOME}/.s5cfg-${count}
			fi
			count="`/usr/bin/expr ${count} + 1`"
		done
	fi

	if ( [ "${S3_HOST_BASE}" != "" ] )
	then
		/bin/sed -i "s/XXXXHOSTBASEXXXX/${S3_HOST_BASE}/" ${HOME}/.s5cfg
		/bin/echo "host_base = ${S3_HOST_BASE}" >> ${HOME}/.s5cfg
		/bin/echo "alias s5cmd='/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${S3_HOST_BASE}'" >> /root/.bashrc
	fi
fi
