#!/bin/bash
# *****************************************************************
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# *****************************************************************

echo -e "\nValidating deployment values ... "

resourceInputValidation()
{
    VARIABLE_VALUE=$1
  	
    #echo "$VARIABLE_VALUE value must not contain '{}\\!@#$%^&*()_-+'"
    if [[ ${VARIABLE_VALUE}  =~ ['\\!@#$%^&*()-+_'] ]]; then
	    echo 1
    else
        echo 0
    fi
}

printErrorMsg()
{
    VAR_NAME=$1
    echo -e "${Red}\nIncorrect deployment values set.${Color_Off}"
    echo -e "${Red}\n${VAR_NAME} contains non-numeric input. Ensure the right numeric input is specified.${Color_Off}"
    exit 1;
}

#
# Check for any special characters within the console_route_prefix
# 
if [[ $ingress_subdomain_prefix =~ ^\. ]] || [[ $ingress_subdomain_prefix =~ ^\- ]]; 
then 
    echo -e "${Red}\n\"ingress_subdomain_prefix\" value must not bein with dot or hyphen.${Color_Off}"
	exit 1
fi

if [ "${ingress_subdomain_prefix: -1}" = "." ] || [ "${ingress_subdomain_prefix: -1}" = "-" ]
then
	echo -e "${Red}\n\"ingress_subdomain_prefix\" value must not end with dot . or - character.${Color_Off}"
	exit 1
fi

if [[ ${ingress_subdomain_prefix}  =~ ['\\!@#$%^&*()_+'] ]]; then
  	echo -e "${Red}\n\"ingress_subdomain_prefix\" value must not contain '{}\\!@#$%^&*()_+'${Color_Off}"
	exit 1
fi

#
# Check for inter component relationship and validate
# - Push cannot be enabled alone without enabling Server
#
if [ "${mfppush_enabled}" = "true" ] && [ "${mfpserver_enabled}" = "false" ]
then
	echo -e "${Red}\nServer component must be enabled to use Push. Set \"mfpserver_enabled\" to true.${Color_Off}"
	exit 1
fi

# Only LiveUpdate cannot be enabled alone without enabling Server
if [ "${mfpliveupdate_enabled}" = "true" ] && [ "${mfpserver_enabled}" = "false" ]
then
	echo -e "\n${Red}Server component must be enabled to use LiveUpdate. Set \"mfpserver_enabled\" to true.${Color_Off}"
	exit 1
fi

if [ "${mfpanalytics_enabled}" = "true" ]
then

    if [ "${elasticsearch_persistence_storageClassName}" = "" ] && [ "${elasticsearch_persistence_claimName}" = "" ]
    then
        echo -e "${Red}\nFor Analytics, either storage class name or existing Persistent Volume Claim name (PVC) has to be set.${Color_Off}"
        echo -e "${Red}\nSet the value for one of the deployment parameters \"elasticsearch_persistence_storageClassName\" or \"elasticsearch_persistence_claimname\".${Color_Off}"
	    exit 1
    fi  

	${CASE_FILES_DIR}/install/common/storage_validation.sh es
	if [ $? -ne 0 ]; then
		echo -e "${Red}\nElasticsearch persistence setting validation failed.${Color_Off}"
		exit $RC
	fi	
fi


#
# DB Schema special character validation
# 
validateDBSchema()
{
    DB_SCH=$1
    if [[ ${DB_SCH}  =~ ['\\!@#$%^&*()+-'] ]]
    then
        echo "db_schema=${DB_SCH}"
        echo -e "${Red}\nDatabase schema values must not contain any special character other than '_'${Color_Off}"
        echo -e "${Red}\nCorrect the Database schema name(s) and try again.${Color_Off}"
        exit 1
    fi
}
#
# namespace special character validation
# 
if [[ ${_GEN_ES_NAMESPACE}  =~ ['\\!@#$%^&*()+'] ]]
then
  	echo -e "${Red}\n\"es_namespace\" value must not contain any special character other than '-' ${Color_Off}"
    echo -e "\n${Red}Correct the deployment value - \"es_namespace\" and try again.${Color_Off}"
	exit 1
fi

validateDBSchema ${_GEN_SERVER_DB_SCHEMA}
validateDBSchema ${_GEN_LU_DB_SCHEMA}
validateDBSchema ${_GEN_AC_DB_SCHEMA}

#
# resource cpu/memory input validation
#

read -r -d '' DEPLOYMENT_VALUES << EOM
dbinit_resources_requests_cpu
dbinit_resources_requests_memory
dbinit_resources_limits_cpu
dbinit_resources_limits_memory
mfpserver_resources_requests_cpu
mfpserver_resources_requests_memory
mfpserver_resources_limits_cpu
mfpserver_resources_limits_memory
mfppush_resources_requests_cpu
mfppush_resources_requests_memory
mfppush_resources_limits_cpu
mfppush_resources_limits_memory
mfpliveupdate_resources_requests_cpu
mfpliveupdate_resources_requests_memory
mfpliveupdate_resources_limits_cpu
mfpliveupdate_resources_limits_memory
mfpanalytics_recvr_resources_requests_memory
mfpanalytics_recvr_resources_requests_memory
mfpanalytics_recvr_resources_limits_cpu
mfpanalytics_recvr_resources_limits_memory
mfpanalytics_resources_requests_cpu
mfpanalytics_resources_requests_memory
mfpanalytics_resources_limits_cpu
mfpanalytics_resources_limits_memory
mfpappcenter_resources_requests_cpu
mfpappcenter_resources_requests_memory
mfpappcenter_resources_limits_cpu
mfpappcenter_resources_limits_memory
elasticsearch_persistence_size
elasticsearch_data_resources_requests_cpu
elasticsearch_data_resources_requests_memory
elasticsearch_data_resources_limits_cpu
elasticsearch_data_resources_limits_memory
elasticsearch_master_resources_requests_cpu
elasticsearch_master_resources_requests_memory
elasticsearch_master_resources_limits_cpu
elasticsearch_master_resources_limits_memory
EOM

ERRORED_INPUTS=""

for deploymentValue in $(echo $DEPLOYMENT_VALUES)
do
	RC=(resourceInputValidation ${!deploymentValue} $deploymentValue)
    RC=$?
    if [ $RC -ne 0 ]
    then
        ERRORED_INPUTS = "${ERRORED_INPUTS}\n${deploymentValue}"
    fi
done

COUNT_ERRORS=$(echo -e ${ERRORED_INPUTS} | sed '/^[[:space:]]*$/d' | wc -l)
if [ $COUNT_ERRORS -ne 0 ]
then
    echo -e "\n${Red}Correct the deployment values and try again.${Color_Off}"
    echo -e "\n${Red}Ensure the following deployment values for resource inputs are set correctly.${Color_Off}"
    echo -e ${ERRORED_INPUTS}
    exit 1
fi
