#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : Set standard collations
#######################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

collations="`/bin/grep -o "COLLATE=.*" ${1} | /bin/grep '^[^\s]*' | /usr/bin/cut -d' ' -f1 | /bin/sed 's/;$//g' | /usr/bin/sort -u | /usr/bin/uniq`"

for collation in ${collations}
do
	/bin/sed -i "s/${collation}/COLLATE=utf8mb4_unicode_ci/g" $1
done

charsets="`/bin/grep -o "CHARSET=.* " ${1} | /usr/bin/cut -d ' ' -f1 | /usr/bin/sort -u | /usr/bin/uniq`"

for charset in ${charsets}
do
	/bin/sed -i "s/${charset}/CHARSET=utf8mb4/g" $1
done
