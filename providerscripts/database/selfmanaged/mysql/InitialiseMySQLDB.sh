#!/bin/sh
############################################################################
# Description: This script initialises the MySQL db instance ready for use.
# It can be either a local database or a remote managed database. 
# Once this script has run, an empty database with a known name will have been
# created along with our database username and password. The root user will have
# been disabled 
# Author: Peter Winter
# Date: 15/01/2017
############################################################################
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
#################################################################################
#################################################################################
#set -x

HOST=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

IP_MASK="`${HOME}/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
CLOUDHOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

if ( [ -f /tmp/original_credentials.dat ] )
then
	DB_U="`/bin/grep DATABASE_USERNAME /tmp/original_credentials.dat | /usr/bin/awk -F':' '{print $NF}'`"
	DB_P="`/bin/grep DATABASE_PASSWORD /tmp/original_credentials.dat | /usr/bin/awk -F':' '{print $NF}'`"
	DB_N="`/bin/grep DATABASE_NAME /tmp/original_credentials.dat | /usr/bin/awk -F':' '{print $NF}'`"
	/bin/rm /tmp/original_credentials.dat
else
	DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
	DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
	DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"
fi

if ( [ ! -d ${HOME}/runtime/mysql-init ] )
then
	/bin/mkdir -p ${HOME}/runtime/mysql-init
fi

/bin/cp ${HOME}/providerscripts/database/selfmanaged/mysql/live/mysql.sql ${HOME}/runtime/mysql-init/initialiseDB.sql
/bin/sed -i "s/XXXXDB_NXXXX/${DB_N}/g" ${HOME}/runtime/mysql-init/initialiseDB.sql
/bin/sed -i "s/XXXXDB_UXXXX/${DB_U}/g" ${HOME}/runtime/mysql-init/initialiseDB.sql
/bin/sed -i "s/XXXXDB_PXXXX/${DB_P}/g" ${HOME}/runtime/mysql-init/initialiseDB.sql
/bin/sed -i "s/XXXXIP_MASKXXXX/${IP_MASK}/g" ${HOME}/runtime/mysql-init/initialiseDB.sql

${HOME}/utilities/processing/RunServiceCommand.sh mysql start

#try with no password set
/usr/bin/mysql -A < ${HOME}/runtime/mysql-init/initialiseDB.sql
#make sure by trying with password
if ( [ "$?" != "0" ] )
then
	/usr/bin/mysql -A --force -u root -p${DB_P} < ${HOME}/runtime/mysql-init/initialiseDB.sql
fi

/bin/cp ${HOME}/providerscripts/database/selfmanaged/mysql/live/mysql.config /etc/mysql/my.cnf
/bin/sed -i "s/XXXXDB_PORTXXXX/${DB_PORT}/g" /etc/mysql/my.cnf

${HOME}/utilities/processing/RunServiceCommand.sh mysql restart
