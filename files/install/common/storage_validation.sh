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

COMPONENT=$1

echo -e "${Bold}\nValidating storage specifications ...\n${Color_Off}"

checkStorageSettings()
{
    persistence_storageClassName=$1
    persistence_claimname=$2
    NAMESPACE=$3
    COMPONENT_DESC=$4

    # check if the storage class exists
    if [ "${persistence_storageClassName// }" != "" ]
    then
        echo -e "\nChecking if the storage class - ${persistence_storageClassName} exists for ${COMPONENT_DESC}..."
        oc get sc ${persistence_storageClassName} >/dev/null 2>&1
        RC=$?
        if [ $RC -ne 0 ] ; then
            echo -e "\nInvalid storage class name (${persistence_storageClassName}) for the deployment value - ${COMPONENT_DESC}_persistence_storageClassName."
            exit $RC
        fi

        STORAGE_PROVISIONER=$(oc get sc ${persistence_storageClassName} -o json | jq .provisioner  | sed "s/\"//g")

        if [[ ${STORAGE_PROVISIONER} == *"block"* ]]; then
            echo -e "\n${persistence_storageClassName} storage class is a \"block storage\"."
            echo -e "\nPlease use any file storage based Storageclass."
            exit 2
        fi

        if [[ ${persistence_storageClassName} == *"block"* ]]; then
            echo -e "\n${persistence_storageClassName} storage class is a \"block storage\"."
            echo -e "\nPlease use any file storage based storage class."
            exit 2
        fi
    fi

    # check the status of pvc 
    if [ "${persistence_claimname// }" != "" ]
    then
        echo -e "\nChecking if the Persistent Volume Claim (PVC) - ${Cyan}${persistence_claimname}${Color_Off} exists..."
        oc get pvc -n ${NAMESPACE} ${persistence_claimname} >/dev/null 2>&1
        RC=$?
        if [ $RC -ne 0 ]
        then
            echo -e "\nPersistent Volume Claim name (${persistence_claimname}) set for ${COMPONENT_DESC} doesn't exists." 
            exit $RC
        else
            PVC_STATUS=$(oc get pvc -n ${NAMESPACE} ${persistence_claimname} -o json | jq .status.phase | sed "s/\"//g")
            if [ "${PVC_STATUS}" != "Bound" ]
            then
                echo -e "\nPersistent Volume Claim name (${persistence_claimname}) set for ${COMPONENT_DESC} is not in Bound status."
                exit 1
            fi
        fi  
    fi
}

if [ "${COMPONENT}" = "es" ]
then
    COMPONENT_DESC="Elasticsearch"
    checkStorageSettings "${elasticsearch_persistence_storageClassName}" "${elasticsearch_persistence_claimName}" "${_GEN_ES_NAMESPACE}" "${COMPONENT_DESC}"
fi

echo "Storage validation completed."