if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi

BUILDOS="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'BUILDOS'`"


>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallSoftwareProperties.sh"
${HOME}/installscripts/InstallSoftwareProperties.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh ${BUILDOS} 

>&2 /bin/echo "${0} InstallDatabaseServer.sh"
${HOME}/installscripts/InstallDatabaseServer.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} &
#>&2 /bin/echo "${0} InstallCurl.sh"
#${HOME}/installscripts/InstallCurl.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallLibSocketSSL.sh"
#${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
#${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} 

>&2 /bin/echo "${0} InstallEmailUtil.sh"
${HOME}/installscripts/InstallEmailUtil.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallSysStat.sh"
#${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallRsync.sh"
#${HOME}/installscripts/InstallRsync.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallJQ.sh"
#${HOME}/installscripts/InstallJQ.sh ${BUILDOS} 
#>&2 /bin/echo "${0} InstallCron.sh"
#${HOME}/installscripts/InstallCron.sh ${BUILDOS} 
>&2 /bin/echo "${0} InstallMonitoringGear.sh"
${HOME}/installscripts/InstallMonitoringGear.sh 


