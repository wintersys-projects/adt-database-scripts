#!/bin/sh

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
	if ( [ "`${HOME}/application/db/maria/VerifyApplicationDBInstallation.sh`" = "1" ] )
	then
		/bin/echo "1"
	else
		/bin/echo "0"
	fi
fi
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	if ( [ "`${HOME}/application/db/mysql/VerifyApplicationDBInstallation.sh`" = "1" ] )
	then
		/bin/echo "1"
	else
		/bin/echo "0"
	fi
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	if ( [ "`${HOME}/application/db/postgres/VerifyApplicationDBInstallation.sh`" = "1" ] )
	then
		/bin/echo "1"
	else
		/bin/echo "0"
	fi
fi
