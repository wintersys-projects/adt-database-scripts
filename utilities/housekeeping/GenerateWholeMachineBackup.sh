if ( [ ! -d ${HOME}/machinedump ] )
then
  /bin/mkdir ${HOME}/machinedump
fi

archive_name="database"

count="1"
/bin/ls /tmp/dusty.$$
 
while ( [ "$?" != "0" ] && [ "${count}" -lt "5" ] )
do
  count="`/usr/bin/expr ${count} + 1`"
  cd ${HOME}/runtime  
  /usr/bin/tar -cvpf ${HOME}/machinedump/${archive_name}_runtime.tar . 
  /usr/bin/tar cpf ${HOME}/machinedump/${archive_name}_hidden.tar `/usr/bin/find / -type f -name '.*' -not -path "${HOME}/machinedump/*" -not -path "/var/www/html/*" -not -path '/dev/*' -not -path '/proc/*' -not -path  '/sys/*' -not -path '/tmp/*' -not -path '/run/*' -not -path '/mnt/*' -not -path '/media/*' -not -path '/lost+found/*'`
  /usr/bin/tar -cvpf ${HOME}/machinedump/${archive_name}_backup.tar --exclude="${HOME}/machinedump/*" --exclude='dev/*' --exclude='proc/*' --exclude='sys/*' --exclude='tmp/*' --exclude='run/*' --exclude='mnt/*' --exclude='media/*' --exclude='lost+found/*' / 
done

if ( [ "${count}" = "5" ] )
then
  ${HOME}/providerscripts/email/SendEmail.sh "FAILED TO GENERATE WHOLE MACHINE BACKUP on the webserver" "It hasn't been possible to generate a whole machine backup on the webserverr machine" "ERROR"
else 
  /bin/echo "Whole Machine Backup Successfully generated"
fi
