#!/bin/sh
#################################################################################################################
# Author: Peter Winter
# Date  : 10/4/2016
# Description : This script is the main script for building a database server. It is called by "cloud-init" when
# a new database server is built using a whole machine backup archive
#################################################################################################################
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
#######################################################################################################
set -x

USER_HOME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"
/bin/echo 'export HOME="/home/'${USER_HOME}'"' >> /home/${USER_HOME}/.bashrc
HOME="/home/${USER_HOME}"

if ( [ -d ${HOME}/logs ] )
then
	/bin/rm ${HOME}/logs/*
fi

out_file="initialbuild/database-build-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${HOME}/logs/${out_file}
err_file="initialbuild/database-build-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${HOME}/logs/${err_file}

MYSQL_USER="mysql"
MYSQL_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
/usr/sbin/adduser --disabled-password --gecos "" ${MYSQL_USER}
/bin/echo ${MYSQL_USER}:${MYSQL_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd

#/bin/echo "${0} Installing Database"
#${HOME}/installscripts/InstallDatabase.sh

#BASELINE_DB_REPOSITORY_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'BASELINEDBREPOSITORY'`"

#/bin/echo "${0} Initialising Database"
#${HOME}/providerscripts/database/InitialiseDatabase.sh

#BYPASS_DB_LAYER="`${HOME}/utilities/config/ExtractConfigValue.sh 'BYPASSDBLAYER'`"

if ( [ -f ${HOME}/runtime/DB_APPLICATION_INSTALLED ] )
then
	/bin/rm ${HOME}/runtime/DB_APPLICATION_INSTALLED
fi





