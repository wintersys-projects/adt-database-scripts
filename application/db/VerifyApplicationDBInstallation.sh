if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
then
	${HOME}/application/branding/ApplyApplicationBranding.sh
	${HOME}/application/db/maria/InstallApplicationDB.sh

fi
if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
then
	${HOME}/application/branding/ApplyApplicationBranding.sh
	${HOME}/application/db/mysql/InstallApplicationDB.sh
fi

if ( [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/utilities/config/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	${HOME}/application/branding/ApplyApplicationBranding.sh
	${HOME}/application/db/postgres/InstallApplicationDB.sh
fi
