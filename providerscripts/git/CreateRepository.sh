#!/bin/sh
######################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script creates a repository
######################################################################################################
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

repository_username="${1}"
repository_name="${2}"
provider_name="${3}"
repository_password="${4}"

if ( [ "${provider_name}" = "bitbucket" ] )
then
	/usr/bin/curl -X POST -v -u ${repository_username}:${repository_password} -H "Content-Type: application/json" https://api.bitbucket.org/2.0/repositories/${repository_username}/${repository_name} -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'
fi
if ( [ "${provider_name}" = "github" ] )
then
	/usr/bin/curl -u "${repository_username}:${repository_password}" https://api.github.com/user/repos -d '{"name":"'${repository_name}'","private":"true"}'
fi
if ( [ "${provider_name}" = "gitlab" ] )
then
	APPLICATION_REPOSITORY_TOKEN="`${HOME}/utilities/config/ExtractConfigValue.sh 'APPLICATIONREPOSITORYTOKEN'`"
	/usr/bin/curl --header "PRIVATE-TOKEN: ${APPLICATION_REPOSITORY_TOKEN}" -F "name=${repository_name}" https://gitlab.com/api/v3/projects
fi
