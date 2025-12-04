#!/bin/sh

if ( [ "`${HOME}/utilities/remote/ConnectToPostgresDB.sh "\dt" "raw" | /bin/grep "^zzzz$"`" != "" ] )
then
        /bin/echo "1" 
else
        /bin/echo "0" 
fi
