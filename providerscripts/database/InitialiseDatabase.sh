#!/bin/sh
####################################################################################
# Description: This script coordinates, based on provider, the installation and initialisation
# of the database that the application is going to be installed into. 
# Date: 18/11/2016
# Author: Peter Winter
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
#####################################################################################
#####################################################################################
#set -x

CLOUDHOST="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'CLOUDHOST'`"

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ]  )
then
	${HOME}/providerscripts/database/selfmanaged/mariadb/InitialiseMariaDB.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	${HOME}/providerscripts/database/selfmanaged/mysql/InitialiseMySQLDB.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	${HOME}/providerscripts/database/selfmanaged/postgres/InitialisePostgresDB.sh
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	if ( [ "${CLOUDHOST}" = "digitalocean" ] )
	then
		${HOME}/providerscripts/database/dbaas/digitalocean/mysql/InitialiseMySQLDB.sh
	fi
	if ( [ "${CLOUDHOST}" = "exoscale" ] )
	then
		${HOME}/providerscripts/database/dbaas/exoscale/mysql/InitialiseMySQLDB.sh
	fi
	if ( [ "${CLOUDHOST}" = "linode" ] )
	then
		${HOME}/providerscripts/database/dbaas/linode/mysql/InitialiseMySQLDB.sh
	fi
	if ( [ "${CLOUDHOST}" = "vultr" ] )
	then
		${HOME}/providerscripts/database/dbaas/vultr/mysql/InitialiseMySQLDB.sh
	fi
fi

if ( [ "`${HOME}/providerscripts/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
        if ( [ "${CLOUDHOST}" = "digitalocean" ] )
        then
                ${HOME}/providerscripts/database/dbaas/digitalocean/postgres/InitialisePostgres.sh
        fi
        if ( [ "${CLOUDHOST}" = "exoscale" ] )
        then
                ${HOME}/providerscripts/database/dbaas/exoscale/postgres/InitialisePostgres.sh
        fi
        if ( [ "${CLOUDHOST}" = "linode" ] )
        then
                ${HOME}/providerscripts/database/dbaas/linode/postgres/InitialisePostgres.sh
        fi
        if ( [ "${CLOUDHOST}" = "vultr" ] )
        then
                ${HOME}/providerscripts/database/dbaas/vultr/postgres/InitialisePostgres.sh
        fi
fi

${HOME}/providerscripts/email/SendEmail.sh "A single node database has been started" "a single node database has been started and initialised" "INFO"
/bin/touch ${HOME}/runtime/DB_INITIALISED
