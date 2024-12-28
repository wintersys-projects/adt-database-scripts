if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"


>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}

if ( [ "${1}" = "preinstall" ] )
then
  scripts="`/bin/cat ${HOME}/installscripts/InstallCoreSoftware.sh | /bin/grep BUILDOS | /bin/grep -v "Up.*" | /usr/bin/awk '{print $1}'`"
  
  package_names=""

  for script in ${scripts}
  do
        script="`/bin/echo ${script} | /bin/sed -e 's,\${HOME},'${HOME}',g'`"
        package_names="${package_names} `/bin/cat ${script} | /bin/grep DEBIAN_FRONTEND | /usr/bin/awk '{print $8}' | /usr/bin/sort -u | /usr/bin/uniq | /usr/bin/tr '\n' ' '`"
  done

  apt=""
  if ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
  then
        apt="/usr/bin/apt-get"
  elif ( [ "`${HOME}/providerscripts/utilities/config/ExtractBuildStyleValues.sh "PACKAGEMANAGER" | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
  then
        apt="/usr/sbin/apt-fast"
  fi

  if ( [ "${apt}" != "" ] )
  then
        if ( [ "${BUILDOS}" = "ubuntu" ] )
        then
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install ${package_names}
        fi
        if ( [ "${BUILDOS}" = "debian" ] )
        then
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install ${package_names}
        fi
  fi
fi


>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSoftwareProperties.sh"
${HOME}/installscripts/InstallSoftwareProperties.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallCurl.sh"
${HOME}/installscripts/InstallCurl.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallLibSocketSSL.sh"
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSendEmail.sh"
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallDatabaseServer.sh"
${HOME}/installscripts/InstallDatabaseServer.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallMonitoringGear.sh"
${HOME}/installscripts/InstallMonitoringGear.sh 
>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh ${BUILDOS} 

