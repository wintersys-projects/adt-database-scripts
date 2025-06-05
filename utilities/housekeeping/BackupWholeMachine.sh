#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2023
# Description: This script will make a complete machine backup which can be used to restore a working
# solution and you can schedule this to run from cron if you want to or you can use this as a way of
# building your machines more quickly in general. If you simply build a particular machine type from
# an archive set that this scipt has produced it should build more quickly for you than building a brand
# new virgin machine
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
#set -x

HOME="`/bin/cat /home/homedir.dat`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"

machine_type=""

if ( [ "`/usr/bin/hostname | /bin/grep '\-rp-'`" ] )
then
        machine_type="proxy"
elif ( [ "`/usr/bin/hostname | /bin/grep '^ws-'`" ] )
then
        machine_type="webserver"
elif ( [ "`/usr/bin/hostname | /bin/grep '^auth-'`" ] )
then
        machine_type="authenticator"
fi

if ( [ ! -d /home/backup ] )
then
        /bin/mkdir /home/backup
fi

/bin/cp -r ${HOME}/* /home/backup

/bin/rm /home/backup/runtime/webserver_configuration_settings.dat
/bin/rm /home/backup/runtime/buildstyles.dat

backup_bucket="`/bin/echo "${WEBSITE_URL}"-whole-machine-backup | /bin/sed 's/\./-/g'`-${machine_type}"

${HOME}/providerscripts/datastore/MountDatastore.sh ${backup_bucket}

${HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${backup_bucket}

if ( [ ! -d /tmp/dump ] )
then
        /bin/mkdir /tmp/dump
else
        /bin/rm -r /tmp/dump/*
fi

excludes="dev proc sys tmp run mnt media lost+found"

includes="`/usr/bin/ls /`"

for exclude in ${excludes}
do
        includes="`/bin/echo ${includes} | /bin/sed -e "s;${exclude};;g" -e 's/  / /g'`"
done

count="1"
count1="1"

for include in ${includes}
do
        if ( [ -d /${include} ] )
        then
                /usr/bin/tar -cpv -f /tmp/dump/backup-${count}.tar  --exclude="*${SERVER_USER}*" --exclude="*var/www/*" /${include}/.

                while ( [ "$?" != "0" ] && [ "${count1}" -lt "5" ] )
                do
                        count1="`/usr/bin/expr ${count1} + 1`"
                        /bin/sleep 5
                        /usr/bin/tar -cpv -f /tmp/dump/backup-${count}.tar  --exclude="*${SERVER_USER}*" --exclude="*var/www/*" /${include}/.

                done

                if ( [ "${count1}" = "5" ] )
                then
                        ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO COMPLETE FULL MACHINE BACKUP" "There was some sort of issue making a full machine backup" "ERROR"
                else
                        ${HOME}/providerscripts/datastore/PutToDatastore.sh /tmp/dump/backup-${count}.tar  ${backup_bucket}
                fi
                count="`/usr/bin/expr ${count} + 1`"
        fi
done

cd /home/${SERVER_USER}/runtime

/usr/bin/tar -cvp -f /tmp/dump/runtime.tar  --exclude="*webserver_configuration_settings.dat*" --exclude="buildstyles.dat" .
${HOME}/providerscripts/datastore/PutToDatastore.sh /tmp/dump/runtime.tar  ${backup_bucket}

/bin/rm -r /tmp/dump
