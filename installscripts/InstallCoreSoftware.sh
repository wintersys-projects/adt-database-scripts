if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi

>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
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
>&2 /bin/echo "${0} InstallSendEmail.sh"
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS}


${HOME}/installscripts/InstallMonitoringGear.sh
. ${HOME}/installscripts/InstallDatastoreTools.sh

