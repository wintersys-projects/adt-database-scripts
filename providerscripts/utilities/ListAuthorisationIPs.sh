#!/bin/sh
######################################################################################
# Author : Peter Winter
# Date   : 11/08/2021
# Description: If this is an authorisation server this script will extract the ip addresses
# that users have entered and store them in a file in the S3 datastore which the main application
# webservers will look for and make adjustments to their firewalls accordingly.
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
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh AUTHORISATIONSERVER:2`" = "1" ] )
then

    if ( [ ! -d ${HOME}/runtime/authorisationips ] )
    then
        /bin/mkdir ${HOME}/runtime/authorisationips
    fi

    export HOME="/home/`/bin/cat /home/homedir.dat | /usr/bin/awk -F'/' '{print $NF}'`"
    prefix="`/usr/bin/run ${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "show tables" | /usr/bin/tail -2 | /usr/bin/head -1 | /usr/bin/awk -F'_' '{print $1}'`"
    records="`/usr/bin/run ${HOME}/providerscripts/utilities/ConnectToMySQLDB.sh "select params from ${prefix}_convertforms_conversions where state='1';" | /bin/grep "IP Address" | /usr/bin/awk -F'"' '{print $4,$8}'`"

    for record in ${records}
    do
            clean_records="${clean_records}"`/bin/echo ${record} | /bin/grep http | /bin/sed 's/^.*\///g'`" "
            clean_records="${clean_records}"`/bin/echo ${record} | /bin/grep -v http`":"
    done

    clean_records="`/bin/echo ${clean_records} | /bin/sed 's/ //g' | /bin/sed 's/:/ /g' | /bin/sed 's/ $//g' | /usr/bin/awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}'`"
    currentips=""

    for record in ${clean_records}
    do
        if ( [ "`/bin/echo ${record} |  /bin/grep -vE '25[6-9]|2[6-9][0-9]|[3-9][0-9][0-9]' | /bin/grep -Eo '(([0-9]{1,2}|1[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9]{1,2}|2[0-4][0-9]|25[0-5]){1}'`" = "" ] )
       then
          isurl="1"
          isipaddress="0"
       else
          isurl="0"
          isipaddress="1"
       fi

       if ( [ "${isurl}" = "1" ] )
       then
           if ( [ "${currentips}" != "" ] )
           then
               /bin/echo "${currenturl}:${currentips}" >> ${HOME}/runtime/processingips.$$
           fi
           currenturl="${record}"
           currentips=""
       fi

       if ( [ "${isipaddress}" = "1" ] )
       then
           currentips="${currentips} ${record}"
       fi
    done

    if ( [ "${currentips}" != "" ] )
    then
        /bin/echo "${currenturl}:${currentips}" >> ${HOME}/runtime/processingips.$$
    fi

    start="1"

    while read line
    do
        currenturl="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $1}'`"
        currentips="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $NF}'`"
        configbucket="`/bin/echo ${currenturl} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
        configbucket="${configbucket}-config"

        if ( [ "${start}" = "1" ] )
        then
            /bin/rm ${HOME}/runtime/authorisationips/${configbucket}
            start="0"
        fi

        for ipaddress in ${currentips}
        do
            if ( [ "`/bin/grep ${ipaddress} ${HOME}/runtime/authorisationips/${configbucket}`" = "" ] )
            then
                /bin/echo "${ipaddress}" >> ${HOME}/runtime/authorisationips/${configbucket}
            fi
        done
    done <  ${HOME}/runtime/processingips.$$

    buckets="`/bin/ls ${HOME}/runtime/authorisationips/* | /bin/sed 's/^.*\///g'`"

    for bucket in ${buckets}
    do
        ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/authorisationips/${bucket} allauthorisationips.dat ${bucket}
    done

    /bin/rm ${HOME}/runtime/processingips.$$
fi
