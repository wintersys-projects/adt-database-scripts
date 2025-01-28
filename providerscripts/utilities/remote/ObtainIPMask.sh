VPC_IP_RANGE="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'VPCIPRANGE'`" 

if ( [ "`/bin/echo ${VPC_IP_RANGE} | /usr/bin/awk -F'/' '{print $NF}'`" = "24" ] )
then
        ip_mask="`/bin/echo ${VPC_IP_RANGE} | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`"
        ip_mask="${ip_mask}.%"
elif ( [ "`/bin/echo ${VPC_IP_RANGE} | /usr/bin/awk -F'/' '{print $NF}'`" = "16" ] )
then
        ip_mask="`/bin/echo ${VPC_IP_RANGE} | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}'`"
        ip_mask="${ip_mask}.%.%"
elif ( [ "`/bin/echo ${VPC_IP_RANGE} | /usr/bin/awk -F'/' '{print $NF}'`" = "8" ] )
then
        ip_mask="`/bin/echo ${VPC_IP_RANGE} | /bin/grep -oE '[0-9]{1,3}'`"
        ip_mask="${ip_mask}.%.%.%"
fi

/bin/echo ${ip_mask}
