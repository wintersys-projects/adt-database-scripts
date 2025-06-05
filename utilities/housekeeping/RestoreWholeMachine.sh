#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date :  9/4/2023
# Description: This will build a new machine from a whole machine backup stored in the datastore
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


backup_bucket="`/bin/echo "${WEBSITE_URL}"-whole-machine-backup | /bin/sed 's/\./-/g'`-${machine_type}"

if ( [ ! -d /tmp/dump ] )
then
        /bin/mkdir /tmp/dump
else
        /bin/rm -r /tmp/dump/* 2>/dev/null
fi

archives="`${HOME}/providerscripts/datastore/ListFromDatastore.sh ${backup_bucket}`"

for archive in ${archives}
do
        ${HOME}/providerscripts/datastore/GetFromDatastore.sh ${backup_bucket}/${archive} /tmp/dump
done

${HOME}/providerscripts/datastore/GetFromDatastore.sh ${backup_bucket}/*runtime* /tmp/dump

archive_list=""

for archive in ${archives}
do
        archive_list="${archive_list} /tmp/dump/${archive}"
done

for archive in ${archive_list}
do
        /usr/bin/tar -xvf ${archive} --keep-newer-files -C / &
done

/usr/bin/tar -xvf /tmp/dump/*runtime* -C ${HOME}/runtime

/usr/bin/find ${HOME} -type d -exec chmod 755 {} \;
/usr/bin/find ${HOME} -type f -exec chmod 750 {} \;
/usr/bin/find ${HOME} -type f -exec chown ${SERVER_USER}:root {} \;

/bin/rm -r /tmp/dump
