DB_U="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBUSERNAME'`"
DB_P="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBPASSWORD'`"
DB_N="`${HOME}/utilities/config/ExtractConfigValue.sh 'DBNAME'`"

if ( [ "`/bin/echo ${DB_U} | /bin/grep ':::'`" != "" ] )
then
	DB_U="`/bin/echo ${DB_U} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $2}'`"
fi

if ( [ "`/bin/echo ${DB_P} | /bin/grep ':::'`" != "" ] )
then
	DB_P="`/bin/echo ${DB_P} | /bin/sed 's/:::/ /g' | /usr/bin/awk '{print $2}'`"
fi

${HOME}/utilities/config/StoreConfigValue.sh 'DBUSERNAME' "${DB_U}"       
${HOME}/utilities/config/StoreConfigValue.sh 'DBPASSWORD' "${DB_P}"  
