#!/bin/sh
########################################################################################################
# Description: When you make extract a backup of your database, you extract out generic placeholder values
# from your database backup, you can then change these generic valued placeholders with deployment specific values.
# When you "RemoveApplicationBranding" as you make a backup, specific values are replaced with generic placeholders
# and here is where these generic placeholders can be replaced with deployment specific values again.  
# Author: Peter Winter
# Date: 17/05/2017
########################################################################################################
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
IP_MASK="`${HOME}/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
FROM_EMAIL="`${HOME}/utilities/config/ExtractConfigValue.sh 'EMAILUSERNAME'`"
DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
WEBSITE_DISPLAY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME' | /bin/sed 's/_/ /g'`"
WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME}  | /bin/sed 's/_/ /g' | /usr/bin/tr '[:lower:]' '[:upper:]'`"
WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/_/ /g' | /usr/bin/tr '[:upper:]' '[:lower:]'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d'.' -f2-`"

target=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	target="${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql"
fi

if ( [ -f ${target} ] )
then
	domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"

	/bin/sed -i "s/ApplicationDomainSpec/${domainspecifier}/g" ${target}
	/bin/sed -i "s/https:\/\/@/https:\/\//g" ${target}
	/bin/sed -i "s/www.applicationdomain.tld/${WEBSITE_URL}/g" ${target}
	/bin/sed -i "s/@applicationdomain.tld/@${ROOT_DOMAIN}/g" ${target}
	/bin/sed -i "s/applicationdomain.tld/${ROOT_DOMAIN}/g" ${target}
	/bin/sed -i "s/http:\/\/mail.applicationdomain.tld/http:\/\/mail.${ROOT_DOMAIN}/g" ${target}
	/bin/sed -i "s/https:\/\/@/https:\/\//g" ${HOME}/backups/installDB/${target}

	/bin/sed -i "s/The GreatApplication/${WEBSITE_DISPLAY_NAME}/g" ${target}
	/bin/sed -i "s/GreatApplication/${WEBSITE_DISPLAY_NAME}/g" ${target}
	/bin/sed -i "s/GREATAPPLICATION/${WEBSITE_DISPLAY_NAME_UPPER}/g" ${target}
	/bin/sed -i "s/THE GREATAPPLICATION/${WEBSITE_DISPLAY_NAME_UPPER}/g" ${target}
	FROM_EMAIL="`${HOME}/utilities/config/ExtractConfigValue.sh 'EMAILUSERNAME'`"
	/bin/sed -i "s/XXX@YYY/${FROM_EMAIL}/g" ${target}
	/bin/sed -i "s/XXXXXXXXXX/${DB_U}/g" ${target}
	IP_MASK="`${HOME}/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
	/bin/sed -i "s/YYYYYYYYYY/${IP_MASK}/g" ${target}
	/bin/sed -i "s/THE THE/THE/g" ${target}
	/bin/sed -i "s/The The/The/g" ${target}
fi
