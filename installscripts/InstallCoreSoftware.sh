if ( [ ! -d ${HOME}/runtime/installedsoftware ] )
then
  /bin/mkdir -p ${HOME}/runtime/installedsoftware
fi
pids=""
>&2 /bin/echo "${0} UpdateAndUpgrade.sh"
${HOME}/installscripts/UpdateAndUpgrade.sh ${BUILDOS}
>&2 /bin/echo "${0} InstallGo.sh"
${HOME}/installscripts/InstallGo.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallSoftwareProperties.sh"
${HOME}/installscripts/InstallSoftwareProperties.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallCurl.sh"
${HOME}/installscripts/InstallCurl.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallLibSocketSSL.sh"
${HOME}/installscripts/InstallLibioSocketSSL.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallLibnetSSLLeay.sh"
${HOME}/installscripts/InstallLibnetSSLLeay.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallNetworkManager.sh"
${HOME}/installscripts/InstallNetworkManager.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallSendEmail.sh"
${HOME}/installscripts/InstallSendEmail.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallSysStat.sh"
${HOME}/installscripts/InstallSysStat.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallFirewall.sh"
${HOME}/installscripts/InstallFirewall.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallRsync.sh"
${HOME}/installscripts/InstallRsync.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallDatabaseClient.sh"
${HOME}/installscripts/InstallDatabaseClient.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallDatabaseServer.sh"
${HOME}/installscripts/InstallDatabaseServer.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallJQ.sh"
${HOME}/installscripts/InstallJQ.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallCron.sh"
${HOME}/installscripts/InstallCron.sh ${BUILDOS} &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallMonitoringGear.sh"
${HOME}/installscripts/InstallMonitoringGear.sh &
pids="${pids} $!"
>&2 /bin/echo "${0} InstallDatastoreTools.sh"
${HOME}/installscripts/InstallDatastoreTools.sh ${BUILDOS} &
pids="${pids} $!"

for pid in ${pids}
do
        wait ${pid}
done
