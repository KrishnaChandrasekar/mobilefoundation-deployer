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

echo -e "${Bold}\nSetting up Ingress secret.${Color_Off}\n"

if [ "${ingress_secret}" = "" ]
then 
    oc get secret ${INGRESS_SECRET_NAME} -n openshift-ingress  > /dev/null 2>&1
    RC=$?
    
    if [ $RC -eq 0 ]; then
        oc get secret ${INGRESS_SECRET_NAME} -n openshift-ingress --export -o yaml | oc apply --namespace=${_SYSGEN_MF_NAMESPACE} -f -
    fi

    oc get secret ${INGRESS_SECRET_NAME} -n ${_SYSGEN_MF_NAMESPACE} >/dev/null 2>&1
    TLS_SECRET_EXISTS=$?

    if [ $TLS_SECRET_EXISTS -ne 0 ]
    then
        echo -e "\n${Purple}Ingress secret name (${INGRESS_SECRET_NAME}) doesn't exists.${Color_Off}"
        #
        # Generate keys/certs for TLS secret
        #
        ${CASE_FILES_DIR}/install/mf/setup_tls_manual.sh "${ingress_subdomain_prefix}.${INGRESS_HOSTNAME}" "${INGRESS_SECRET_NAME}"
        if [ $? -ne 0 ]
        then
            echo -e "${Red}Ingress secret creation failed.${Color_Off}"
            exit 1
        fi
    else
        echo -e "\nIngress secret name successfully exported to the namespace - ${_SYSGEN_MF_NAMESPACE}."
        echo -e "${BGreen}  OK${Color_Off}\n"
    fi
else
    echo -e "\nUsing the custom ingress secret name : ${ingress_secret} \n"
    oc get secret ${ingress_secret} -n ${_SYSGEN_MF_NAMESPACE} >/dev/null 2>&1
    TLS_SECRET_EXISTS=$?

    if [ $TLS_SECRET_EXISTS -ne 0 ]
    then
        echo -e "${Red}\nIngress secret(${ingress_secret}) doesn't exists. ${Color_Off}"
        echo -e "${Cyan}\nEnsure the secret(${ingress_secret}) is created within the namespace \"${_SYSGEN_MF_NAMESPACE}\"${Color_Off}" 
        echo -e "${Cyan}\nProceeding without ingress secret name ...${Color_Off}"
    fi
fi
