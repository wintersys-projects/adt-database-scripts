#!/bin/sh
#################################################################################
# Description: If you have an file permissions or owner settings that need to be
# enforced, you can put them here
# Author: Peter Winter
# Date: 17/01/2017
#################################################################################
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
##################################################################################
##################################################################################
#set -x

set -x

HOME="`/bin/cat /home/homedir.dat`"

SERVER_USER="`/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"

/usr/bin/find ${HOME} -type d -exec chmod 755 {} \;
/usr/bin/find ${HOME} -type d -exec chmod 640 {} \;
/usr/bin/find ${HOME} -type d -exec chown ${SERVER_USER}:root {} \;
/bin/chmod 700 ${HOME}/.ssh
/bin/chmod 644 ${HOME}/.ssh/authorized_keys
/bin/chmod 600 ${HOME}/id_*
/bin/chmod 644 ${HOME}/id_*pub

#/bin/chmod -R 640 ${HOME}/.ssh/*
#/bin/chown -R ${SERVER_USER}:root ${HOME}/.ssh
#/bin/chmod 640 ${HOME}/super/Super.sh
#/bin/chown ${SERVER_USER}:root ${HOME}/super/Super.sh
#/bin/chmod -R 640 ${HOME}/runtime
#/bin/chown ${SERVER_USER}:root ${HOME}/runtime
#/bin/chmod 644 ${HOME}/runtime/DATABASE_READY

