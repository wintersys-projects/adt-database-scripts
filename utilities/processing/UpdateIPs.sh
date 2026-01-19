# -l/bin/sh
##################################################################################################
# Author : Peter Winter
# Date   : 10/4/2016
# Description : This script updates the DB IP address
##################################################################################################
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
##########################################################################################
##########################################################################################
#set -x

WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
MULTI_REGION="`${HOME}/utilities/config/ExtractConfigValue.sh 'MULTIREGION'`"

ip="`${HOME}/utilities/processing/GetIP.sh`" 
public_ip="`${HOME}/utilities/processing/GetPublicIP.sh`"

#Sometimes (very rarely) the ip is not set for some reason so have to hope we are alright next time instead
if ( [ "${ip}" = "" ] || [ "${public_ip}" = "" ] )
then
        exit
fi

${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${ip} databaseip "no"
${HOME}/providerscripts/datastore/config/toolkit/PutToConfigDatastore.sh ${public_ip} databasepublicip "no"

if ( [ "${MULTI_REGION}" = "1" ] )
then
	multi_region_bucket="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-multi-region"
	${HOME}/providerscripts/datastore/dedicated/PutToDatastore.sh ${public_ip} ${multi_region_bucket}/dbaas_ips 
fi



