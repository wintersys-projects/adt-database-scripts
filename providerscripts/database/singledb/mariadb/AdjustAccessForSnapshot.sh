#!/bin/sh
###################################################################################
# Description: This  will adjust so that the DB is accessible from snapshotted machines
# Date: 18/11/2016
# Author : Peter Winter
###################################################################################
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

HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"

/usr/bin/mariadb -u ${DB_U} -p${DB_P} ${DB_N} --host="localhost" --port="${DB_PORT}" -e "GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${HOST}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;"
