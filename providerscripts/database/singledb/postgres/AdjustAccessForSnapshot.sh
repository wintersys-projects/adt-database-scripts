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

postgres_config="`/usr/bin/find / -name pg_hba.conf -print`"

/bin/echo "host       all              postgres           ${HOST}/0          md5" >> ${postgres_config}

${HOME}/providerscripts/utilities/RunServiceCommand.sh postgresql restart || /usr/sbin/runuser -l "postgres" -c "/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data/ -l logfile restart"

if ( [ "$?" != "0" ] )
then
    /usr/bin/su postgres -c "/usr/local/pgsql/bin/pg_ctl reload -D /usr/local/pgsql/data/ -l /home/postgres/logfile"
fi

export PGPASSWORD="${DB_P}" && /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} -c "DROP DATABASE ${DB_N}"
if ( [ "$?" != "0" ] )
then
    /usr/bin/sudo -su postgres /usr/bin/psql -h ${HOST} -p ${DB_PORT} -c "DROP DATABASE ${DB_N}"
fi
export PGPASSWORD="${DB_P}" && /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;"
if ( [ "$?" != "0" ] )
then
    /usr/bin/sudo -su postgres /usr/bin/psql -h ${HOST} -p ${DB_PORT} -c "CREATE DATABASE ${DB_N} WITH OWNER ${DB_U} ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;"
fi
export PGPASSWORD="${DB_P}" && /usr/bin/psql -U ${DB_U} -h ${HOST} -p ${DB_PORT} -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_N} to ${DB_U};"
if ( [ "$?" != "0" ] )
then
    /usr/bin/sudo -su postgres /usr/bin/psql -h ${HOST} -p ${DB_PORT} -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_N} to ${DB_U};"
fi
