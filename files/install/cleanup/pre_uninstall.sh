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

OPERATOR_NAME=$1
DEPLOYED_NAMESPACE=$2

CRD_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_crd.yaml"
CR_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/operator.yaml"

SA_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/service_account.yaml"
ROLE_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/role.yaml"
ROLE_BINDING_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/role_binding.yaml"
SCC_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/scc.yaml"

if [ -d "${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}" ]
then
    echo 
    echo -e "${Bold}Initiate cleanup of the deployed resources.${Color_Off}"
    echo 
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${CR_YAML}
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${SA_YAML}
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${SCC_YAML}
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${OPERATOR_YAML}
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${ROLE_YAML}
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${ROLE_BINDING_YAML}
    oc delete  --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} -f ${CRD_YAML}
fi

oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret ${OPERATOR_NAME}-image-docker-pull-${DEPLOYED_NAMESPACE}

if [ "${OPERATOR_NAME}" = "mf" ]
then
    echo 
    echo -e "${Bold}Cleanup of mf created secrets.${Color_Off}"
    echo 
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret mobilefoundation-db-secret
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret serverlogin
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret analyticslogin
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret appcntrlogin
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret mfpanalytics-recvrsecret 
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret mfpliveupdate-clientsecret
    oc delete --ignore-not-found --namespace ${DEPLOYED_NAMESPACE} secret ${OPERATOR_NAME}-image-docker-pull-${_SYSGEN_MF_NAMESPACE}
fi

if [ "${OPERATOR_NAME}" = "es" ]
then
    rm "${CASE_FILES_TEMP_DIR}/es.txt"   > /dev/null 2>&1

    oc patch ESOperator/ibm-mf -p '{"metadata":{"finalizers":[]}}' --type=merge  > /dev/null 2>&1
else
    oc patch MFOperator/ibm-mf -p '{"metadata":{"finalizers":[]}}' --type=merge  > /dev/null 2>&1
fi

# patching es/mf deployment
oc patch ${OPERATOR_NAME}operator.${OPERATOR_NAME}.ibm.com ${DEPLOYED_NAMESPACE} -p '{"metadata":{"finalizers":[]}}' --type=merge   > /dev/null 2>&1


TIMESTAMP=$(date '+%Y%m%d_%H%M_%S')

mv ${CASE_FILES_TEMP_DIR} ${CASE_FILES_TEMP_DIR}-${TIMESTAMP}

echo 
echo "Cleanup of the deployed ${OPERATOR_NAME} resources completed."
echo -e "${BGreen}  OK${Color_Off}\n"
