tables="`${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh "show tables" | /usr/bin/tail -n +2`"

#Make absolutely certain we are all on INNODB

for table in ${tables}
do
  #  /usr/bin/mariadb -A -u ${DB_U} -p${DB_P} ${DB_N} --host="${HOST}" --port="${DB_PORT}" -e "ALTER TABLE ${table} ENGINE = INNODB;"
   ${HOME}/providerscripts/utilities/remote/ConnectToMySQLDB.sh  "ALTER TABLE ${table} ENGINE = INNODB;"
done
