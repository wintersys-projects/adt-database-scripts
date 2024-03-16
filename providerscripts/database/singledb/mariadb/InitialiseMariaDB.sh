#!/bin/sh
############################################################################
# Description: This script initialises the maria db instance ready for use.
# It can be either a local database or a remote managed database. 
# Once this script has run, an empty database with a known name will have been
# created. 
# Author: Peter Winter
# Date: 15/01/2017
############################################################################
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
#################################################################################
#################################################################################
#set -x

HOST=""

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBaaSHOSTNAME'`"
else
    HOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'MYPUBLICIP'`"
fi

IP_MASK="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'IPMASK'`"
DB_PORT="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DBPORT'`"
CLOUDHOST="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'CLOUDHOST'`"
BUILDOS="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDOS'`"

#Older style user setup where necessary, might have to change this with time
if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    /bin/echo "use mysql;
update user set user=\"${DB_U}\" where user='root';
flush privileges;
create database ${DB_N};
ALTER DATABASE ${DB_N} CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'localhost' IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'127.0.0.1' IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${HOST}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${IP_MASK}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT SESSION_VARIABLES_ADMIN ON *.* TO \"${DB_U}\";
flush privileges;" > ${HOME}/runtime/initialiseDB.sql
else
    /bin/echo "use mysql;
CREATE USER \"${DB_U}\" IDENTIFIED BY \"${DB_P}\";
flush privileges;
create database ${DB_N};
ALTER DATABASE ${DB_N} CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'localhost' IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@'127.0.0.1' IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${HOST}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB_N}.* TO \"${DB_U}\"@\"${IP_MASK}\" IDENTIFIED BY \"${DB_P}\" WITH GRANT OPTION;
drop user 'root'@'localhost';
drop user 'mysql'@'localhost';
flush privileges;" > ${HOME}/runtime/initialiseDB.sql
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
    count="0"
    /bin/sed -i '/GRANT SESSION/d' ${HOME}/runtime/initialiseDB.sql
    /bin/sed -i '/drop user/d' ${HOME}/runtime/initialiseDB.sql
    /bin/sed -i '/CREATE USER/d' ${HOME}/runtime/initialiseDB.sql
    
    /usr/bin/mysql -f -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port="${DB_PORT}" < ${HOME}/runtime/initialiseDB.sql
    
    while ( [ "$?" != "0" ] && [ "${count}" -lt "10" ] )
    do
        /bin/sleep 30
        count="`/usr/bin/expr ${count} + 1`"
        /usr/bin/mysql -f -A -u ${DB_U} -p${DB_P} --host="${HOST}" --port="${DB_PORT}" < ${HOME}/runtime/initialiseDB.sql
    done
else
    /usr/sbin/service mariadb start
    #try with no password set
    /usr/bin/mysql -A < ${HOME}/runtime/initialiseDB.sql
    #make sure by trying with password
    if ( [ "$?" != "0" ] )
    then
       /usr/bin/mysql -A --force -u root -p${DB_P} < ${HOME}/runtime/initialiseDB.sql
    fi
fi

if ( [ -f /etc/mysql/mariadb.conf.d/50-server.cnf ] )
then
    /bin/sed -i.bak '/bind-address/d' /etc/mysql/mariadb.conf.d/50-server.cnf
    /bin/sed -i.bak "s/3306/${DB_PORT}/" /etc/mysql/mariadb.conf.d/50-server.cnf
else
    /bin/sed -i.bak '/bind-address/d' /etc/mysql/my.cnf
    /bin/sed -i.bak "s/3306/${DB_PORT}/" /etc/mysql/my.cnf
fi


if ( [ "`/bin/grep "${DB_PORT}" /etc/mysql/mariadb.conf.d/50-server.cnf`" = "" ] )
then
    if ( [ -f /etc/mysql/mariadb.conf.d/50-server.cnf ] )
    then
        /bin/echo "[mysqld]" >> /etc/mysql/mariadb.conf.d/50-server.cnf
        /bin/echo "port        = ${DB_PORT}" >> /etc/mysql/mariadb.conf.d/50-server.cnf
        /bin/echo "bind-address        = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
    fi
elif ( [ "`/bin/grep "${DB_PORT}" /etc/mysql/my.cnf`" = "" ] )
then
    /bin/echo "[mysqld]" >> /etc/mysql/my.cnf
    /bin/echo "port        = ${DB_PORT}" >> /etc/mysql/my.cnf
    /bin/echo "bind-address        = 0.0.0.0" >> /etc/mysql/my.cnf
fi

/usr/sbin/service mariadb restart
