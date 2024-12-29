#!/bin/sh

while ( [ ! -f /usr/bin/mariadb ] && [ ! -f /usr/bin/mysql ] && [ ! -f /usr/bin/psql ] )
do
  /bin/sleep 5
done
