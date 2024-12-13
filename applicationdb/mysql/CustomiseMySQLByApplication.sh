#!/bin/sh
######################################################################################################
# Description: If the MySQL Database needs any settings specific to an application, they can set here.
# There is an example here for the moodle application, and I apply the serfix tool to the wordpress
# database to fix a serialization issue that wordpress has when it is used in the way I use it
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
set -x

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="localhost"
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    /bin/sed -i '/^\[mysqld\]/a binlog_format=mixed' /etc/mysql/my.cnf
    /bin/sed -i '/^\[mysqld\]/a innodb_file_per_table=ON' /etc/mysql/my.cnf
    /bin/sed -i '/^\[mysqld\]/a innodb_default_row_format=dynamic' /etc/mysql/my.cnf
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

    ${HOME}/installscripts/InstallSerFix.sh ${BUILDOS}

    if ( [ -f ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql ] )
    then
        /bin/cat ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql | /usr/local/bin/serfix > ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql.fixed
        /bin/mv ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql.fixed ${HOME}/backups/installDB/${WEBSITE_NAME}DB.sql
    fi
fi

