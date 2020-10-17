#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

#####################################################################################
# settings

    scriptDir=$(cd $(dirname "$0") && pwd);
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    source $scriptDir/.lib/functions.sh

#####################################################################################
# environment vars
    if [ -z "$PARAMETERS_FILE" ]; then export PARAMETERS_FILE=$scriptDir/create.parameters.json; fi    

#####################################################################################
# vars

  parametersFile=$(assertFile $PARAMETERS_FILE) || exit
  templateFile=$(assertFile $scriptDir/create.template.json) || exit
  stateDir="$scriptDir/state"
  stateFile="$stateDir/create.state.json"
  loginSSHOutFile="$stateDir/loginSSH.sh"

  FAILED=0
  parameters=$(cat $parametersFile | jq .)
  id=$( echo $parameters | jq -r '.parameters.id.value' )
  azLocation=$( echo $parameters | jq -r '.parameters.azLocation.value' )

  projectPrefix=$id"-solace-ci-controller"
  resourceGroup=$projectPrefix-rg



echo
echo "##########################################################################################"
echo "# Create Azure Resources"
echo "# Resource Group : '$resourceGroup'"
echo "# Location       : '$azLocation'"
echo

#####################################################################################
# Prepare Dirs
mkdir $stateDir > /dev/null 2>&1
rm -f $stateDir/*

#####################################################################################
# Resource Group
echo ">>> Creating Resource Group ..."
resp=$(az group create \
  --name $resourceGroup \
  --location "$azLocation" \
  --tags project=$projectPrefix \
  --verbose)
if [[ $? != 0 ]]; then echo ">>> ERROR: creating resource group"; exit 1; fi
echo $resp | jq
echo " >>> Success."

#####################################################################################
# Run ARM Template
echo ">>> Creating Resources ..."
az deployment group create \
  --name $projectPrefix"_Deployment" \
  --resource-group $resourceGroup \
  --template-file $templateFile \
  --parameters $parametersFile \
  --verbose \
  > "$stateFile"
if [[ $? != 0 ]]; then echo ">>> ERROR: creating resources."; FAILED=1; fi

#####################################################################################
# Update State

if [[ $FAILED != 0 ]]; then
  echo ">>> ERROR: $scriptName";
  rm -rf $stateDir
  exit 1;
else
  cp $parametersFile $stateDir
fi
# create login script
loginPwd=$(cat $stateFile | jq -r '.properties.outputs.loginPassword.value' )
loginSSH=$(cat $stateFile | jq -r '.properties.outputs.loginSSH.value' )
echo "####" > $loginSSHOutFile
echo "echo 'password: $loginPwd'" >> $loginSSHOutFile
echo $loginSSH >> $loginSSHOutFile
chmod u+x $loginSSHOutFile
echo ">>> Success."
echo ">>> log in: $loginSSHOutFile"
cat $loginSSHOutFile

###
# The End.
