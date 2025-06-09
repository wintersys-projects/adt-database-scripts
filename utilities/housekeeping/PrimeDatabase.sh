HOME="`/bin/cat /home/homedir.dat`"

/bin/rm ${HOME}/runtime/FIREWALL-ACTIVE

USER_NAME="`/usr/bin/awk -F: '{ print $1}' /etc/passwd | /bin/grep "X*X"`"

original_user="`/bin/ls -l /home | /bin/grep "X*X" | /usr/bin/awk '{print $NF}' | /bin/grep -v "${USER_NAME}"`"

webserver_config="`/bin/cat ${HOME}/runtime/WEBSERVER_CONFIG_LOCATION.dat`"

/bin/sed -i "s/${orginal_user}/${USER_NAME}/g ${webserver_config}

/bin/rm -r /home/${original_user}
