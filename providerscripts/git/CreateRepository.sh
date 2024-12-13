#!/bin/sh
#############################################################################################
# Author: Peter Winter
# Date  : 04/07/2016
# Description : This is a script which creates a git repository
#############################################################################################
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
######################################################################################
######################################################################################
#set -x

repository_username="${1}"
repository_password="${2}"
website_name="${3}"
period="${4}"
build_identifier="${5}"
provider_name="${6}"

if ( [ "${provider_name}" = "bitbucket" ] )
then
    /usr/bin/curl -X POST -v -u ${repository_username}:${repository_password} -H "Content-Type: application/json" https://api.bitbucket.org/2.0/repositories/${repository_username}/${website_name}-db-${period}-${build_identifier} -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks" }'
fi
if ( [ "${provider_name}" = "github" ] )
then
    repo_name="${website_name}-db-${period}-${build_identifier}"
    /usr/bin/curl -u "${repository_username}:${repository_password}" https://api.github.com/user/repos -d '{"name":"'$repo_name'","private":"true"}'
fi
if ( [ "${provider_name}" = "gitlab" ] )
then
    APPLICATION_REPOSITORY_TOKEN="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYTOKEN'`"
    repo_name="${website_name}-db-${period}-${build_identifier}"
    /usr/bin/curl --header "PRIVATE-TOKEN: ${APPLICATION_REPOSITORY_TOKEN}" -F "name=${repo_name}" https://gitlab.com/api/v3/projects
fi
