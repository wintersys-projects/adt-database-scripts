#!/bin/sh
###########################################################################################
# Author: Peter Winter
# Date : 10/04/2016
# Description: Commits specified file and pushes to origin
###########################################################################################
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
########################################################################################
########################################################################################
#set -x

if ( [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ "$4" = "" ] )
then
    /bin/echo "Usage : ${0} : <files> <commit message> <repository provider> <repository name>"
    exit
fi

if ( [ "$5" = "" ] || [ "$6" = "" ] || [ "$7" = "" ] )
then
    repository_provider="${3}"
    APPLICATION_REPOSITORY_USERNAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'`"
    APPLICATION_REPOSITORY_PASSWORD="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPASSWORD'`"
    APPLICATION_REPOSITORY_OWNER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYOWNER'`"

    APPLICATION_REPOSITORY_NAME="${4}"
else
    repository_provider="${3}"
    APPLICATION_REPOSITORY_USERNAME="$5"
    APPLICATION_REPOSITORY_PASSWORD="$6"
    APPLICATION_REPOSITORY_OWNER="$7"
    APPLICATION_REPOSITORY_NAME="$4"
fi

/usr/bin/git add ${1}
/usr/bin/git commit -m "${2}"
/usr/bin/git branch -M main

if ( [ "${repository_provider}" = "bitbucket" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@bitbucket.org/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
fi
if ( [ "${repository_provider}" = "github" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@github.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
fi
if ( [ "${repository_provider}" = "gitlab" ] )
then
    /usr/bin/git remote add origin https://${APPLICATION_REPOSITORY_USERNAME}:${APPLICATION_REPOSITORY_PASSWORD}@gitlab.com/${APPLICATION_REPOSITORY_OWNER}/${APPLICATION_REPOSITORY_NAME}.git
fi
/usr/bin/git push -u -f origin main

