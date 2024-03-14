#!/bin/sh
#####################################################################################
# Description: This script ensures that the necessary configuration is robustly in place
# for the database server to function within the framework
# Author: Peter Winter
# Date: 15/01/2017
####################################################################################
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
###################################################################################
###################################################################################
#set -x

if ( [ -f ${HOME}/credentials/shit ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "0" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "credentials/shit"
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
else
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh "credentials/shit"

    if ( [ "`/bin/cat /tmp/shit`" = "" ] )
    then
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
        /bin/rm /tmp/shit
    fi
fi

if ( [ ! -f ${HOME}/.ssh/shit ] && [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "credentials/shit"`" = "1" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh credentials/shit ${HOME}/.ssh/shit
fi

${HOME}/providerscripts/utilities/UpdateIP.sh

/bin/chmod 400 ${HOME}/credentials/shit
/bin/chmod 400 ${HOME}/.ssh/shit

DB_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

DB1_N="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 1`"
DB1_P="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 2`"
DB1_U="`${HOME}/providerscripts/datastore/configwrapper/GetDBCredential.sh "credentials/shit" 3`"

if ( [ "${DB_N}" != "${DB1_N}" ] || [ "${DB_P}" != "${DB1_P}" ] ||  [ "${DB_U}" != "${DB1_U}" ] )
then
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
fi
