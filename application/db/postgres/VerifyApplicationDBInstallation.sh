#!/bin/sh

if ( [ "`${HOME}/utilities/remote/ConnectToPostgresDB.sh "\dt" "raw" | /bin/grep "zzzz.*table"`" != "" ] )
then
        /bin/echo "1" 
else
        /bin/echo "0" 
fi
