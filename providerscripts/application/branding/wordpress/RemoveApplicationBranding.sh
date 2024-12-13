#!/bin/sh
######################################################################################################
# Description: When you make a backup of your database, you extract out deployment specific values
# from your database, you can then store these specific values with generic valued placeholders in the
# backup. When you "ApplyApplicationBranding" as you make a deployment, these generic placeholder values
# can be replaced with deployment specific values again. This means that, for example, your codebase can
# be deployed to different URLs which is essential, if, for example, you want to make a baseline and 
# using one url and to deploy it to different urls as a "product" used by other developers. # Author : Peter Winter
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

domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
    
/bin/sed -i "s/${domainspecifier}/ApplicationDomainSpec/g" applicationDB.sql
/bin/sed -i "s/${WEBSITE_URL}/www.applicationdomain.tld/g" applicationDB.sql
/bin/sed -i "s/@${ROOT_DOMAIN}/@applicationdomain.tld/g" applicationDB.sql
/bin/sed -i "s/${ROOT_DOMAIN}/applicationdomain.tld/g" applicationDB.sql
/bin/sed -i "s/${WEBSITE_DISPLAY_NAME}/GreatApplication/g" applicationDB.sql
/bin/sed -i "s/${WEBSITE_DISPLAY_NAME_UPPER}/GREATAPPLICATION/g" applicationDB.sql
/bin/sed -i "s/${WEBSITE_DISPLAY_NAME_LOWER}-online/application-online/g" applicationDB.sql
/bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" applicationDB.sql
/bin/sed -i "s/@@mail/@mail/g" applicationDB.sql
