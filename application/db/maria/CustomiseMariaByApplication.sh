#!/bin/sh
######################################################################################################
# Description: If the Maria Database needs any settings set specifically for an application, 
# they can set here. By default it there is an example for moodle and I apply a special tool
# "serfix" for wordpress which fixes a serialization issue that wordpress has when I use it 
# the way that I do
# Author: Peter Winter
# Date: 17/01/2017
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
#####################################################################################################
#####################################################################################################
#set -x

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

HOST=""

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
	/bin/sed -i '/^\[mysqld\]/a binlog_format=mixed' /etc/mysql/my.cnf
	/bin/sed -i '/^\[mysqld\]/a innodb_large_prefix=1' /etc/mysql/my.cnf
	/bin/sed -i '/^\[mysqld\]/a innodb_file_per_table=ON' /etc/mysql/my.cnf
	/bin/sed -i '/^\[mysqld\]/a innodb_default_row_format=dynamic' /etc/mysql/my.cnf
	/bin/sed -i '/^\[mysqld\]/a innodb_file_format=Barracuda' /etc/mysql/my.cnf
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
	${HOME}/installscripts/InstallSerFix.sh ${BUILDOS}

	if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] )
	then
		/bin/cat ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /usr/local/bin/serfix > ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql.fixed
		/bin/mv ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql.fixed ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
	fi
fi
