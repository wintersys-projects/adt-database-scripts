#!/bin/sh
#########################################################################################
#Description: This will store the database credentials into the right place in the file system
#Author : Peter Winter
#Date: 05/04/2017
##########################################################################################
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
#######################################################################################
#######################################################################################

export HOME="`/bin/cat /home/homedir.dat`"

/bin/echo "$1" > ${HOME}/credentials/shit
/bin/echo "$2" >> ${HOME}/credentials/shit
/bin/echo "$3" >> ${HOME}/credentials/shit

/bin/cp ${HOME}/credentials/shit ${HOME}/.ssh/shit

${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
