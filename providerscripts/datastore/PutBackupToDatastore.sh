#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: This is a special case of putting a file to the datastore because the
# file that is being put is the backup file of the database. The reason why this is 
# a special case is that if the deployer has configured "multi region backups" then
# when we put the backup archive into the datastore it needs to be stored to all the 
# regions that the deployer has requested for it to be stored in
#####################################################################################
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

file_to_put="$1"
datastore_to_put_in="$2"

datastore_regions="`${HOME}/utilities/config/ExtractConfigValues.sh 'S3HOSTBASE' 'stripped' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g' | /bin/sed 's/config//g'`"
count="0"
for datastore_region in ${datastore_regions}
do
	if ( [ "${count}" != "0" ] )
	then
		suffix="-${count}"
	fi
	if ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTORETOOL:s3cmd'`" = "1" ] )
	then
		if ( [ "${count}" = "0" ] )
		then
			config_file="${HOME}/.s3cfg"
		else
			config_file="${HOME}/.s3cfg-${count}"
		fi

		/usr/bin/s3cmd --config=${config_file}  mb s3://${datastore_to_put_in}${suffix}
		datastore_tool="/usr/bin/s3cmd --force --recursive --multipart-chunk-size-mb=5 --config=${config_file} put "
	elif ( [ "`${HOME}/utilities/config/CheckBuildStyle.sh 'DATASTORETOOL:s5cmd'`" = "1" ]  )
	then
		host_base="`/bin/grep host_base /root/.s5cfg | /bin/grep host_base | /usr/bin/awk -F'=' '{print  $NF}' | /bin/sed 's/ //g'`" 
		/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${datastore_region} mb s3://${datastore_to_put_in}${suffix}
		datastore_tool="/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${datastore_region} cp "
	fi

	count="`/usr/bin/expr ${count} + 1`"
	${HOME}/providerscripts/datastore/MountDatastore.sh ${datastore_to_put_in}${suffix}

	count1="0"
	while ( [ "`${datastore_tool} ${file_to_put} s3://${datastore_to_put_in}${suffix} 2>&1 >/dev/null | /bin/grep "ERROR"`" != "" ] && [ "${count1}" -lt "5" ] )
	do
		/bin/echo "An error has occured `/usr/bin/expr ${count1} + 1` times in script ${0}"
		/bin/sleep 5
		count1="`/usr/bin/expr ${count1} + 1`"
	done 
done
