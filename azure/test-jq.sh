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

  PARAMTERS_TEMPLATE_FILE="./.workflows/template.azure-deploy.parameters.json"
  PARAMETERS_FILE="./state/generated-parameters.json"

#####################################################################################
# test

        # "vm_admin_public_key": {
        #     "value": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoii+97+HRgAP8I8cQEdJ9B4XapMS/OIH4N080aGaiQiN8FUff1569iUIdWSuSjCYdGIsjeSXMzXXlR+WPj0IpAWmKcwkqBJoKdJzH+jXJSWgcXwEZCQDUbZukBBHXvXyI8a5AA0KPoD2l1C+FIHWKEvNlw4zl0aHdikQ357iygbSbmuGjxPa8CoYYTPGz+gU1pIQSbXxiKgJrTfJPP4LZaPD11rWQLm14vKH/edH6OADdfURn9XWY87qTIYfjs7thyYw7TiG3xeMISngPmQIcjV+RPuPUHjQfnIdae8W5KRytJudq2g2FREoTo2bxzUPXc2IKmA0vcXohQrR3rkA8p0Xv+Alq1WoLGJZqYNRndGTc6m8prc+WsRs8KcQzdc+vvm/3IWqkU0793uGuE2+uNHtslNpFt0/3JWEWMpQHLwnJdUuN3xRp4e38SBr/1eDAtFgG4PnsnvArNigXmA9zZUr+iGAKfuamGJpQ8NhCE5iNvweVLv6N8ZT2QUgsRWM= rjgu@Ricardos-MacBook-Pro.local"
        # }


  parametersJson=$(cat $PARAMTERS_TEMPLATE_FILE | jq .)
  echo parametersJson=$parametersJson

  export id="w1"
    parametersJson=$( echo $parametersJson | jq -r '.parameters.id.value=env.id' )
  export zone="1"
    parametersJson=$( echo $parametersJson | jq -r '.parameters.zone.value=env.zone' )
  export vm_admin_username="controller"
    parametersJson=$( echo $parametersJson | jq -r '.parameters.vm_admin_username.value=env.vm_admin_username' )
  
  export vm_admin_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoii+97+HRgAP8I8cQEdJ9B4XapMS/OIH4N080aGaiQiN8FUff1569iUIdWSuSjCYdGIsjeSXMzXXlR+WPj0IpAWmKcwkqBJoKdJzH+jXJSWgcXwEZCQDUbZukBBHXvXyI8a5AA0KPoD2l1C+FIHWKEvNlw4zl0aHdikQ357iygbSbmuGjxPa8CoYYTPGz+gU1pIQSbXxiKgJrTfJPP4LZaPD11rWQLm14vKH/edH6OADdfURn9XWY87qTIYfjs7thyYw7TiG3xeMISngPmQIcjV+RPuPUHjQfnIdae8W5KRytJudq2g2FREoTo2bxzUPXc2IKmA0vcXohQrR3rkA8p0Xv+Alq1WoLGJZqYNRndGTc6m8prc+WsRs8KcQzdc+vvm/3IWqkU0793uGuE2+uNHtslNpFt0/3JWEWMpQHLwnJdUuN3xRp4e38SBr/1eDAtFgG4PnsnvArNigXmA9zZUr+iGAKfuamGJpQ8NhCE5iNvweVLv6N8ZT2QUgsRWM= rjgu@Ricardos-MacBook-Pro.local"
    parametersJson=$( echo $parametersJson | jq -r '.parameters.vm_admin_public_key=env.vm_admin_public_key' )

  echo $parametersJson | jq . > $PARAMETERS_FILE    

  cat $PARAMETERS_FILE | jq .

###
# The End.
