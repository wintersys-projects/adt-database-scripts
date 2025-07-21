#!/bin/sh
##############################################################################################################################
# Description: This script implements database specific backup procedures. If you want to support additional new types of
# database, then, you can add to this file, for example, mongodb or something like that
# Author: Peter Winter
# Date: 28/05/2017
##############################################################################################################################
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
#set -x

websiteDB="${1}"

if ( [ -f /usr/bin/mariadb-dump ] )
then
	mysql_dump="/usr/bin/mariadb-dump --ssl"
	mysql="/usr/bin/mariadb"
else
	mysql_dump="/usr/bin/mysqldump --set-gtid-purged=OFF --ssl-mode=REQUIRED --skip-column-statistics"
	mysql="/usr/bin/mysql"
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
then
	HOST="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBIDENTIFIER'`"
else
	HOST="`${HOME}/utilities/processing/GetIP.sh`"
fi

DB_PORT="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPORT'`"
WEBSITE_URL="`${HOME}/utilities/config/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"

DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"


#The standard troop of SQL databases
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ]  )
then
	#Dump the database to an sql file
	if ( [ "`${mysql} -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e 'show tables' | /usr/bin/wc -l`" -lt "5" ] )
	then
		/bin/echo "${0} `/bin/date`: Failed to backup database, it seems like the tables are not there" 
		exit
	fi

	/bin/echo "SET SESSION sql_require_primary_key = 0;" > applicationDB.sql
	/bin/echo "DROP TABLE IF EXISTS \`zzzz\`;" >> applicationDB.sql

	tries="1"
	${mysql_dump} --skip-lock-tables --single-transaction --hex-blob --routines --triggers --force -y --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} | /bin/sed -e '/SET @@SESSION.SQL_LOG_BIN= 0;/d' -e '/SET GLOBAL INNODB_STATS_AUTO_RECALC=OFF;/d' -e '/SET GLOBAL INNODB_STATS_AUTO_RECALC=@OLD_INNODB_STATS_AUTO_RECALC;/d' -e '/SET @@GLOBAL.GTID_PURGED=/,/;/d' -e '/SET @@GLOBAL.GTID_PURGED=.*;/d' >> applicationDB.sql

	while ( [ "$?" != "0"  ] && [ "${tries}" -lt "5" ] )
	do
		/bin/sleep 10
		tries="`/usr/bin/expr ${tries} + 1`"
		${mysql_dump} --skip-lock-tables --single-transaction --hex-blob --routines --triggers --force -y --port=${DB_PORT} --host=${HOST} -u ${DB_U} -p${DB_P} ${DB_N} | /bin/sed -e '/SET @@SESSION.SQL_LOG_BIN= 0;/d' -e '/SET GLOBAL INNODB_STATS_AUTO_RECALC=OFF;/d' -e '/SET GLOBAL INNODB_STATS_AUTO_RECALC=@OLD_INNODB_STATS_AUTO_RECALC;/d' -e '/SET @@GLOBAL.GTID_PURGED=/,/;/d' -e '/SET @@GLOBAL.GTID_PURGED=.*;/d' >> applicationDB.sql
	done

	if ( [ "${tries}" = "5" ] )
	then
		/bin/echo "${0} `/bin/date`: Had trouble makng a backup of your database. Please investigate..." 
		${HOME}/providerscripts/email/SendEmail.sh "FAILED TO TAKE BACKUP" "I haven't been able to take a database backup, please investigate" "ERROR"
		exit
	fi

	/bin/echo "DROP TABLE IF EXISTS \`zzzz\`;" >> applicationDB.sql
	/bin/echo "CREATE TABLE \`zzzz\` ( \`idxx\` int(10) unsigned NOT NULL, PRIMARY KEY (\`idxx\`) ) Engine=INNODB CHARSET=utf8mb4;" >> applicationDB.sql
	/bin/sed -i -- 's/http:\/\//https:\/\//g' applicationDB.sql
	/bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" applicationDB.sql
	/bin/sed -i '/SESSION.SQL_LOG_BIN/d' applicationDB.sql
	IP_MASK="`${HOME}/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
	/bin/sed -i "s/${IP_MASK}/YYYYYYYYYY/g" applicationDB.sql
	/bin/echo "${0} `/bin/date`: replaced all http with https in the SQL file" 
	/bin/echo "${0} `/bin/date`: Taring the database dump" 

	${HOME}/utilities/processing/StandardiseMySQLCollations.sh ./applicationDB.sql
	#tar the database dump
	/bin/tar cvfz ${websiteDB} applicationDB.sql
	/bin/rm applicationDB.sql
fi

#The postgres SQL database

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	/bin/echo "DROP TABLE zzzz;" > applicationDB.psql
	export PGPASSWORD="${DB_P}" && /usr/bin/pg_dump -U ${DB_U} -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.psql

	if ( [ "$?" != "0" ] )
	then
		/usr/bin/sudo -su postgres /usr/bin/pg_dump -h ${HOST} -p ${DB_PORT} -d ${DB_N} > applicationDB.psql
	fi

	/bin/echo "DROP TABLE IF EXISTS public.zzzz;" >> applicationDB.psql
	/bin/echo "CREATE TABLE public.zzzz ( idxx serial PRIMARY KEY );" >> applicationDB.psql
	/bin/sed -i -- 's/http:\/\//https:\/\//g' applicationDB.psql
	/bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" applicationDB.psql
	IP_MASK="`${HOME}/utilities/config/ExtractConfigValue.sh 'IPMASK'`"
	/bin/sed -i "s/${IP_MASK}/YYYYYYYYYY/g" applicationDB.psql
	/bin/echo "${0} `/bin/date`: replaced all http with https in the SQL file" 
	/bin/echo "${0} `/bin/date`: Taring the database dump"
	/bin/tar cvfz ${websiteDB} applicationDB.psql
	/bin/rm applicationDB.psql
fi
