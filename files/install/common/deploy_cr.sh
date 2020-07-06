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
DEPLOY_NAMESPACE=$2

echo -e "${Bold}\nDeploying the ${OPERATOR_NAME} custom resource.\n${Color_Off}"

CR_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr.yaml"

rm -rf ${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/*.yaml.bak
rm -rf ${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/*.yaml.bak

# Create/Switch Project
${CASE_FILES_DIR}/install/utils/create_project.sh ${DEPLOY_NAMESPACE} ${OPERATOR_NAME}

#  Create the CR (deploy MF)
oc apply --namespace ${DEPLOY_NAMESPACE} -f ${CR_YAML}
RC=$?
if [ $RC -ne 0 ]; then
    echo -e "${Red}\nFailed to apply custom CR for the component - ${OPERATOR_NAME}.${Color_Off}"
    exit $RC
fi

echo ${DEPLOY_NAMESPACE} > "${CASE_FILES_TEMP_DIR}/${OPERATOR_NAME}.txt"