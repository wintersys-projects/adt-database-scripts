#!/bin/sh
########################################################################################
# Author : Peter Winter
# Date   : 10/07/2016
# Description : Cleanup and then shutdown this database instance.
########################################################################################
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
########################################################################################
########################################################################################
#set -x

/bin/echo ""
/bin/echo "#######################################################################"
/bin/echo "Shutting down a database, please wait whilst I clean the place up first"
 
if ( [ "$1" = "backup" ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "dbbackuplock.file"`" = "0" ] )
then
    /bin/echo "Making a daily and an emergency shutdown backup of your database"
    BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
    /bin/echo "Making the daily periodicity backup please wait....."
    ${HOME}/cron/BackupFromCron.sh 'DAILY' ${BUILD_IDENTIFIER} > /dev/null 2>&1
    /bin/echo "Making the special shutdown backup please wait....."
    ${HOME}/cron/BackupFromCron.sh 'SHUTDOWN' ${BUILD_IDENTIFIER} > /dev/null 2>&1
fi

${HOME}/providerscripts/email/SendEmail.sh "A database is being shutdown" "A database is being shutdown" "INFO"

if ( [ "${1}" = "halt" ] )
then
    /usr/sbin/shutdown -h now
elif ( [ "${1}" = "reboot" ] )
then
    /usr/sbin/shutdown -r now
fi
