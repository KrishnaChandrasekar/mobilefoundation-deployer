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
IMG_PULLSECRET=$3

echo -e "${Bold}\nDeploying the ${OPERATOR_NAME} operator.\n${Color_Off}"

CR_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/operator.yaml"

SA_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/service_account.yaml"
cp ${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/service_account_template.yaml ${SA_YAML}

cp ${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr_template.yaml ${CR_YAML}
cp ${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/operator_template.yaml ${OPERATOR_YAML}

# Create Operator & service account
sed -i.bak "s|_IMG_REPO_|${_GEN_IMG_REPO}|g" ${OPERATOR_YAML}
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${OPERATOR_YAML}
sed -i.bak "s|_IMG_PULLPOLICY_|${image_pullPolicy}|g" ${OPERATOR_YAML}
sed -i.bak "s|_IMG_PULLSECRET_|${IMG_PULLSECRET}|g" ${OPERATOR_YAML}
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${SA_YAML}
sed -i.bak "s|_IMG_PULLSECRET_|${IMG_PULLSECRET}|g" ${SA_YAML}

# Create/Switch Project
${CASE_FILES_DIR}/install/utils/create_project.sh ${DEPLOY_NAMESPACE} ${OPERATOR_NAME}

oc apply --namespace ${DEPLOY_NAMESPACE} -f ${SA_YAML}
oc apply --namespace ${DEPLOY_NAMESPACE} -f ${OPERATOR_YAML}

oc adm policy add-scc-to-group ${OPERATOR_NAME}-operator system:serviceaccounts:${DEPLOY_NAMESPACE}
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:${DEPLOY_NAMESPACE}:${OPERATOR_NAME}-operator

rm -rf ${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/*.yaml.bak
rm -rf ${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/*.yaml.bak

# give some time...
sleep 5
