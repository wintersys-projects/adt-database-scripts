#!/bin/sh
######################################################################################################
# Description: When you make a backup of your database, you extract out deployment specific values
# from your database, you can then store these specific values with generic valued placeholders in the
# backup. When you "ApplyApplicationBranding" as you make a deployment, these generic placeholder values
# can be replaced with deployment specific values again. This means that, for example, your codebase can
# be deployed to different URLs which is essential, if, for example, you want to make a baseline and 
# using one url and to deploy it to different urls as a "product" used by other developers. 
# This script removes the application branding when you make a baseline of an application. 
# Author : Peter Winter
# Date: 17/05/2017
######################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d'.' -f2-`"
DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
WEBSITE_DISPLAY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME}  | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"
IP_MASK="`${HOME}/utilities/config/ExtractConfigValue.sh 'IPMASK'`"

target=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	target="applicationDB.sql"
fi

domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"

if ( [ -f ${target} ] )
then
	/bin/sed -i "s/${domainspecifier}/ApplicationDomainSpec/g" ${target}
	/bin/sed -i "s/${WEBSITE_URL}/www.applicationdomain.tld/g" ${target}
	/bin/sed -i "s/@${ROOT_DOMAIN}/@applicationdomain.tld/g" ${target}
	/bin/sed -i "s/${ROOT_DOMAIN}/applicationdomain.tld/g" ${target}
	/bin/sed -i "s/${WEBSITE_DISPLAY_NAME}/GreatApplication/g" ${target}
	/bin/sed -i "s/${WEBSITE_DISPLAY_NAME_UPPER}/GREATAPPLICATION/g" ${target}
	/bin/sed -i "s/${WEBSITE_DISPLAY_NAME_LOWER}-online/application-online/g" ${target}
	/bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" ${target}
	/bin/sed -i "s/@@mail/@mail/g" ${target}
	/bin/sed -i "s/${IP_MASK}/YYYYYYYYYY/g" ${target}
fi

