if ( [ ! -d ${HOME}/machinedump ] )
then
  /bin/mkdir ${HOME}/machinedump
fi

archive_name="database"

SERVER_USER="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSER'`"
SERVER_USER_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'SERVERUSERPASSWORD'`"
DB_USERNAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_PASSWORD="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_NAME="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"


/bin/echo "USERNAME: ${DB_USERNAME}" > ${HOME}/machinedump/db_credentials.dat
/bin/echo "PASSWORD: ${DB_PASSWORD}" >> ${HOME}/machinedump/db_credentials.dat
/bin/echo "DBNAME: ${DB_NAME}" >> ${HOME}/machinedump/db_credentials.dat

count="1"
success="0"

while ( [ "${success}" = "0" ] && [ "${count}" -lt "5" ] )
do
  success="1"
  count="`/usr/bin/expr ${count} + 1`" 
  /bin/echo "USERNAME:${SERVER_USER}" > ${HOME}/machinedump/credentials.dat
  /bin/echo "PASSWORD:${SERVER_USER_PASSWORD}" >> ${HOME}/machinedump/credentials.dat
  /usr/bin/tar cpf ${HOME}/machinedump/${archive_name}_hidden.tar `/usr/bin/find / -type f -name '.*' -not -path "${HOME}/machinedump/*" -not -path "/var/www/html/*" -not -path '/dev/*' -not -path '/proc/*' -not -path  '/sys/*' -not -path '/tmp/*' -not -path '/run/*' -not -path '/mnt/*' -not -path '/media/*' -not -path '/lost+found/*'`
  if ( [ "$?" != "0" ] )
  then
    success="0"
  fi
  /usr/bin/tar -cvpf ${HOME}/machinedump/${archive_name}_backup.tar --exclude="${HOME}/machinedump/*" --exclude='/var/www/html/*' --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' --exclude='tmp/*' --exclude='run/*' --exclude='mnt/*' --exclude='media/*' --exclude='lost+found/*' / 
  if ( [ "$?" != "0" ] )
  then
    success="0"
  fi
done

if ( [ "${count}" = "5" ] )
then
  ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO GENERATE WHOLE MACHINE BACKUP on the webserver" "It hasn't been possible to generate a whole machine backup on the webserverr machine" "ERROR"
else 
  /bin/echo "Whole Machine Backup Successfully generated"
fi
