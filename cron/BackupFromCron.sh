#!/bin/sh
###########################################################################################################
# Description: This script will perform a backup of the database when it is called from cron
# It is called at set periods from cron and if you want to call it manually you can look in the 
# directory ${BUILD_HOME}/helperscripts relating to making backups and baselines for how to backup
# your database manually.
# Look there for further explaination
# Date: 16/11/2016
# Author: Peter Winter
###########################################################################################################
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
####################################################################################
####################################################################################
#set -x

trap cleanup 0 1 2 3 6 9 14 15

cleanup()
{
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "dbbackuplock.file"
    exit
}

period="${1}"
buildidentifier="${2}"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "dbbackuplock.file"`" = "0" ] )
then
    /usr/bin/touch ${HOME}/runtime/dbbackuplock.file
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/dbbackuplock.file 

    if ( [ -f  ${HOME}/runtime/BACKUP_MISSING ] )
    then
        /bin/rm ${HOME}/runtime/BACKUP_MISSING
    fi

    ${HOME}/providerscripts/backupscripts/Backup.sh "${period}" "${buildidentifier}"
    
    count="0"
    while ( [ -f  ${HOME}/runtime/BACKUP_MISSING ] && [ "${count}" -le "5" ] )
    do
        count="`/usr/bin/expr ${count} + 1`"
        /bin/rm ${HOME}/runtime/BACKUP_MISSING
        ${HOME}/providerscripts/backupscripts/Backup.sh "${period}" "${buildidentifier}"
    done

    if ( [ -f  ${HOME}/runtime/BACKUP_MISSING ] )
    then
        /bin/rm ${HOME}/runtime/BACKUP_MISSING
    fi
    
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "dbbackuplock.file"
else
    /bin/echo "script already running"
fi

