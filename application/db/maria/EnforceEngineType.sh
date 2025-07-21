#!/bin/sh
######################################################################################################
# Description: This will set the engine type to INNODB for all tables in the mariadb database
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
#set -x

tables="`${HOME}/utilities/remote/ConnectToMySQLDB.sh "show tables" | /usr/bin/tail -n +2`"

#Make absolutely certain we are all on INNODB

for table in ${tables}
do
	${HOME}/utilities/remote/ConnectToMySQLDB.sh  "ALTER TABLE ${table} ENGINE = INNODB;"
done
