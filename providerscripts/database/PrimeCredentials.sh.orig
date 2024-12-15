
if ( [ ! -f ${HOME}/runtime/CREDENTIALS_PRIMED ] )
then
  ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/credentials/shit credentials/shit
  if ( [ "$?" = "0" ] )
  then
    /bin/touch ${HOME}/runtime/CREDENTIALS_PRIMED
  fi
fi
