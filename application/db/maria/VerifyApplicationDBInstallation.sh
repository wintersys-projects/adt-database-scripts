#!/bin/sh

if ( [ "`${HOME}/utilities/remote/ConnectToMySQLDB.sh "show tables" "raw" | /bin/grep "^zzzz$"`" != "" ] )
then
        /bin/echo "1" 
else
        /bin/echo "0" 
fi
