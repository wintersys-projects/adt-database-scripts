#!/bin/sh
####################################################################################
#Description: This script will setup your crontab for you
# Author: Peter Winter
# Date: 28/01/2017
####################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#####################################################################################
#Setup crontab

/bin/echo "MAILTO=''" > /var/spool/cron/crontabs/root
HOME="`/bin/cat /home/homedir.dat`"

#These scripts run every minute
#/bin/echo "*/1 * * * * export HOME=${HOME} && ${HOME}/providerscripts/database/PrimeCredentials.sh" >> /var/spool/cron/crontabs/root
#/bin/echo "*/1 * * * * export HOME=${HOME} && ${HOME}/providerscripts/utilities/remote/EnsureAccessForWebservers.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/cron/SetupFirewallFromCron.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && /bin/sleep 30 && ${HOME}/providerscripts/utilities/processing/UpdateIPs.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME=${HOME} && ${HOME}/providerscripts/utilities/housekeeping/RemoveExpiredLocks.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/MonitorForOverload.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/IsDatabaseUp.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/1 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/CheckNetworkManagerStatus.sh" >> /var/spool/cron/crontabs/root

#These scripts run every 5 minutes
/bin/echo "*/5 * * * * export HOME="${HOME}" &&  /bin/sleep 23 && ${HOME}/security/MonitorFirewall.sh" >> /var/spool/cron/crontabs/root

#These scripts run ever 10 minutes
/bin/echo "*/10 * * * * export HOME=${HOME} && ${HOME}/providerscripts/utilities/security/EnforcePermissions.sh" >> /var/spool/cron/crontabs/root
/bin/echo "*/10 * * * * export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/MonitorCron.sh" >> /var/spool/cron/crontabs/root

#The scripts run at set times

/bin/echo "2 * * * * export HOME=${HOME} && ${HOME}/cron/BackupFromCron.sh 'HOURLY'" >>/var/spool/cron/crontabs/root
/bin/echo "30 2 * * * export HOME=${HOME} && ${HOME}/cron/BackupFromCron.sh 'DAILY'" >>/var/spool/cron/crontabs/root
/bin/echo "30 3 * * 7 export HOME=${HOME} && ${HOME}/cron/BackupFromCron.sh 'WEEKLY'" >>/var/spool/cron/crontabs/root
/bin/echo "30 4 1 * * export HOME=${HOME} && ${HOME}/cron/BackupFromCron.sh 'MONTHLY'" >>/var/spool/cron/crontabs/root
/bin/echo "30 5 1 Jan,Mar,May,Jul,Sep,Nov * export HOME=${HOME} && ${HOME}/cron/BackupFromCron.sh 'BIMONTHLY'" >>/var/spool/cron/crontabs/root
/bin/echo "22 4 * * *  export HOME="${HOME}" && ${HOME}/providerscripts/utilities/software/UpdateSoftware.sh" >> /var/spool/cron/crontabs/root

/bin/echo "30 3 * * *  export HOME="${HOME}" && ${HOME}/providerscripts/utilities/housekeeping/RemoveExpiredLogs.sh" >> /var/spool/cron/crontabs/root

/bin/echo "@hourly export HOME="${HOME}" && ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh 'dbbackuplock.file'" >> /var/spool/cron/crontabs/root
/bin/echo "@hourly export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/LoadMonitoring.sh" >> /var/spool/cron/crontabs/root

SERVER_TIMEZONE_CONTINENT="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECONTINENT'`"
SERVER_TIMEZONE_CITY="`${HOME}/providerscripts/utilities/config/ExtractConfigValue.sh 'SERVERTIMEZONECITY'`"

/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/utilities/housekeeping/CleanupAtReboot.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export TZ=\":${SERVER_TIMEZONE_CONTINENT}/${SERVER_TIMEZONE_CITY}\"" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME=${HOME} && ${HOME}/providerscripts/utilities/housekeeping/RemoveExpiredLocks.sh reboot" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/utilities/processing/GetIP.sh" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/utilities/software/UpdateInfrastructure.sh" >>/var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/LoadMonitoring.sh 'reboot'" >> /var/spool/cron/crontabs/root
/bin/echo "@reboot export HOME="${HOME}" && ${HOME}/providerscripts/utilities/status/CheckNetworkManagerStatus.sh" >> /var/spool/cron/crontabs/root


#Reload cron
/usr/bin/crontab /var/spool/cron/crontabs/root
