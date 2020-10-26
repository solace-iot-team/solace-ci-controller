#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
source $scriptDir/.lib/functions.sh

#####################################################################################
# environment vars

    if [ -z "$PARAMETERS_FILE" ]; then export PARAMETERS_FILE=$scriptDir/create.parameters.json; fi    
    if [ -z "$AZ_LOCATION" ]; then export AZ_LOCATION="westeurope"; fi    

#####################################################################################
# settings

    parametersFile=$(assertFile $PARAMETERS_FILE) || exit

    stateDir="$scriptDir/state"
    stateFile=$(assertFile $stateDir/create.state.json) || exit

#####################################################################################
# vars

  parameters=$(cat $parametersFile | jq .)
  id=$( echo $parameters | jq -r '.parameters.id.value' )
  azLocation=$AZ_LOCATION

  projectPrefix=$id"-solace-ci-controller"  
  keyVaultName=$projectPrefix

  state=$(cat $stateFile | jq .)
  resourceGroup=$( echo $state | jq -r '.resourceGroup' )


echo ">>> Deleting Resource Group '$resourceGroup' ..."
echo
  az group delete \
    --name $resourceGroup \
    --verbose
  if [[ $? != 0 ]]; then echo ">>> ERROR: deleting resource group"; exit 1; fi
echo ">>> Success."

resp=$(az keyvault purge \
  --name $keyVaultName \
  --location $azLocation \
  --verbose)
if [[ $? != 0 ]]; then echo ">>> ERROR: purging key vault"; exit 1; fi

#####################################################################################
# Remove state
rm -rf $stateDir


###
# The End.
