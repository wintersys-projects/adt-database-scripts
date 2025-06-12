HOME="`/bin/cat /home/homedir.dat`"
BUILDOS="`${HOME}/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"

/bin/rm ${HOME}/runtime/FIREWALL-ACTIVE

#USER_NAME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"

#original_user="`/bin/ls -l /home | /bin/grep "X*X" | /usr/bin/awk '{print $NF}' | /bin/grep -v "${USER_NAME}"`"

#/usr/bin/rsync -avrP /home/${original_user}/* ${HOME}/ --exclude=".ssh" --include='.*' --ignore-existing 

#/bin/rm -r /home/${original_user}

${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS} &
