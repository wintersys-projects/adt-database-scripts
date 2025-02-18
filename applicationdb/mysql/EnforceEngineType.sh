
HOME="`/bin/cat /home/homedir.dat`"

#Make absolutely certain we are all on INNODB
tables="`${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh 'show tables' | /usr/bin/tail -n +2`"

for table in ${tables}
do
   # /usr/bin/mysql -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "ALTER TABLE ${table} ENGINE = INNODB;"
   ${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh "ALTER TABLE ${table} ENGINE = INNODB;"
done
