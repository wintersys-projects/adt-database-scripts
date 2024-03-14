#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: This is the main script for setting up and activating the gateway guardian process
# SMTP services need to be available and active
#######################################################################################
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

BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'`"
WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"

if ( [ "`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}`" = "" ] )
then
    ${HOME}/providerscripts/datastore/MountDatastore.sh "${DATASTORE_CHOICE}" gatewayguardian-${BUILD_IDENTIFIER}
fi

if ( [ "${1}" = "fromcronreset" ] )
then
    /bin/sleep 10
    /bin/mv ${HOME}/runtime/credentials/htpasswd ${HOME}/runtime/credentials/htpasswd.$$
fi

if ( [ ! -d ${HOME}/runtime/credentials ] )
then
    /bin/mkdir ${HOME}/runtime/credentials
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:joomla`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "show tables" | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "select CONCAT_WS('::',username,email) from ${prefix}_users" | /bin/grep -v CONCAT`"
    fi
    
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_users" | /usr/bin/tail -2 |  /usr/bin/head -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT username,email FROM ${prefix}_users" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:wordpress`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "show tables" | /bin/grep '_users' | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "select CONCAT_WS('::',user_login,user_email) from ${prefix}_users"  | /bin/grep -v CONCAT`"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_users" | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT user_login,user_email FROM ${prefix}_users" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:moodle`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "show tables" | /bin/grep '_user' | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "select CONCAT_WS('::',username,email) from ${prefix}_user"  | /bin/grep -v CONCAT`"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_user" | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT username,email FROM ${prefix}_user" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh APPLICATION:drupal`" = "1" ] )
then
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "show tables" | /bin/grep '_users_field_data' | /usr/bin/tail -2  | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "select CONCAT_WS('::',name,mail) from ${prefix}_users_field_data"  | /bin/grep -v CONCAT`"
    fi
    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
    then
        prefix="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "\dt" | /bin/grep "_users" | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk '{print $3}' | /usr/bin/awk -F'_' '{print $1}'`"
        userdetails="`${HOME}/providerscripts/utilities/ConnectToPostgresDB.sh "SELECT name,mail FROM ${prefix}_users_field_data" | /usr/bin/tail -n +3 | /usr/bin/head -n -2 | /bin/sed 's/ //g' | /bin/sed 's/|/::/g'`"
    fi
fi

if ( [ "${userdetails}" = "" ] )
then
    userdetails="bootstrap_user::bootstrap@dummyemail.com"
fi

nousers="`/bin/echo ${userdetails} | /usr/bin/awk -F'::' '{print NF-1}'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] && [ ! -f ${HOME}/runtime/credentials/htpasswd ] )
then
    ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd gatewayguardian-${BUILD_IDENTIFIER}/htpasswd.$$ 
    ${HOME}/providerscripts/datastore/MoveDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history.$$
fi

if ( [ ! -f ${HOME}/runtime/credentials/htpasswd ] && [ "${1}" != "fromcronreset" ] )
then 
    dir="`/usr/bin/pwd`"
    cd ${HOME}/runtime/credentials
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    ${HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history
    cd ${dir}
fi

if ( [ -f ${HOME}/runtime/credentials/htpasswd ] )
then
    credentials="`/bin/grep -v 'placeholder-for-uid-1' ${HOME}/runtime/credentials/htpasswd`"
    if ( [ "${credentials}" != "" ] )
    then
        liveusers="`/usr/bin/wc -w ${credentials} | /usr/bin/awk '{print $1}'`"
    else
        liveusers="0"
    fi
else
    /bin/touch ${HOME}/runtime/credentials/htpasswd 
    liveusers="0"
fi

if ( [ "${nousers}" != "${liveusers}" ] )
then
   for user in ${userdetails}
   do
       username="`/bin/echo ${user} | /usr/bin/awk -F'::' '{print $1}'`"
       email="`/bin/echo ${user} | /usr/bin/awk -F'::' '{print $2}'`"
       if ( [ "`/bin/grep ${username} ${HOME}/runtime/credentials/htpasswd`" = "" ] && [ "${username}" != "" ] && [ "${email}" != "" ] ) 
       then
           user_password="`/usr/bin/openssl rand -base64 10`"
           user_password_digest="`/bin/echo "${user_password}" | /usr/bin/openssl passwd -apr1 -stdin`"
           /bin/echo "${username}:${user_password_digest}" >> ${HOME}/runtime/credentials/htpasswd
           /bin/sed -i "/${username}:/s/LIVE:   //g" ${HOME}/runtime/credentials/htpasswd_plaintext_history
           /bin/echo "LIVE:   ${username}:${user_password}:${email}" >> ${HOME}/runtime/credentials/htpasswd_plaintext_history
           ${HOME}/providerscripts/email/SendEmail.sh "NEW BASIC AUTH CREDENTIALS" "These are your new basic auth credentials username:same as your CMS application username and password:${user_password}" "MANDATORY" "${email}"
       fi
   done
fi
   
if ( [ "`/usr/bin/find ${HOME}/runtime/credentials/htpasswd -type f -mmin -1`" != "" ] )
then

    ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd
    ${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_CHOICE} gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history

    ${HOME}/providerscripts/datastore/PutToDatastore.sh "${DATASTORE_CHOICE}" ${HOME}/runtime/credentials/htpasswd gatewayguardian-${BUILD_IDENTIFIER}/
    ${HOME}/providerscripts/datastore/PutToDatastore.sh "${DATASTORE_CHOICE}" ${HOME}/runtime/credentials/htpasswd_plaintext_history gatewayguardian-${BUILD_IDENTIFIER}/

fi
