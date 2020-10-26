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
    if [ -z "$AZ_LOCATION" ]; then export AZ_LOCATION="westeurope"; fi    

#####################################################################################
# vars

  parametersFile=$(assertFile $PARAMETERS_FILE) || exit
  templateFile=$(assertFile $scriptDir/.workflows/azure-deploy.json) || exit
  stateDir="$scriptDir/state"
  stateFile="$stateDir/create.state.json"
  loginSSHOutFile="$stateDir/loginSSH.sh"

  FAILED=0
  parameters=$(cat $parametersFile | jq .)
  id=$( echo $parameters | jq -r '.parameters.id.value' )
  azLocation=$AZ_LOCATION

  projectPrefix=$id"-solace-ci-controller"
  resourceGroup=$projectPrefix-rg
  
  privateKeyFile=$scriptDir/azure_key
  keyVaultName=$projectPrefix
  vmAdminPublicKeySecretName="vm-admin-public-key"
  vmAdminPrivateKeySecretName="vm-admin-private-key"

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
# Keyvault

ssh-keygen -t rsa -N '' -f $privateKeyFile <<< y

resp=$(az keyvault create \
  --name $keyVaultName \
  --resource-group $resourceGroup \
  --location $azLocation \
  --tags project=$projectPrefix \
  --enabled-for-template-deployment true \
  --verbose)
if [[ $? != 0 ]]; then echo ">>> ERROR: creating key vault"; exit 1; fi
echo $resp | jq
echo " >>> Success."


exit

resp=$(az keyvault secret set \
  --vault-name $keyVaultName \
  --name $vmAdminPublicKeySecretName \
  --file $privateKeyFile.pub \
  --verbose)
if [[ $? != 0 ]]; then echo ">>> ERROR: set key vault secret: $vmAdminPublicKeySecretName"; exit 1; fi
echo $resp | jq
echo " >>> Success."

resp=$(az keyvault secret set \
  --vault-name $keyVaultName \
  --name $vmAdminPrivateKeySecretName \
  --file $privateKeyFile \
  --verbose)
if [[ $? != 0 ]]; then echo ">>> ERROR: set key vault secret: $vmAdminPrivateKeySecretName"; exit 1; fi
echo $resp | jq
echo " >>> Success."

# Example for Workflow
# az keyvault secret download \
#   --vault-name $keyVaultName \
#   --name $vmAdminPrivateKeySecretName \
#   --file "./downloaded.azure_key"

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
publicIpAddress=$(cat $stateFile | jq -r '.properties.outputs.publicIPAddress.value' )
adminUserName=$(cat $parametersFile | jq -r '.parameters.vm_admin_username.value' )
echo "####" > $loginSSHOutFile
echo "ssh -i ./azure_key $adminUserName@$publicIpAddress" >> $loginSSHOutFile
chmod u+x $loginSSHOutFile
echo ">>> Success."
echo ">>> log in: $loginSSHOutFile"
cat $loginSSHOutFile

###
# The End.
