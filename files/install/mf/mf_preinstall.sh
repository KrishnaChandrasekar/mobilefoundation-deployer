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

echo -e "${Bold}\nStarting mf_preinstall ...\n${Color_Off}"

MODE=$1

# Create/Switch Project for ES
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

mkdir -p ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds

cp ${CASE_FILES_DIR}/components/mf/deploy/crds/charts_v1_mfoperator_crd_template.yaml ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/charts_v1_mfoperator_crd.yaml
cp ${CASE_FILES_DIR}/components/mf/deploy/role_template.yaml ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role.yaml
cp ${CASE_FILES_DIR}/components/mf/deploy/role_binding_template.yaml ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role_binding.yaml
cp ${CASE_FILES_DIR}/components/mf/deploy/scc_template.yaml ${CASE_FILES_TEMP_DIR}/components/mf/deploy/scc.yaml

sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/charts_v1_mfoperator_crd.yaml
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role.yaml
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role_binding.yaml
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/mf/deploy/scc.yaml
sed -i.bak "s|_MF_NAMESPACE_|${_SYSGEN_MF_NAMESPACE}|g" ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role_binding.yaml

rm -rf ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/*.yaml.bak
rm -rf ${CASE_FILES_TEMP_DIR}/components/mf/deploy/*.yaml.bak

if [ "$MODE" = "apply" ]
then
    oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/charts_v1_mfoperator_crd.yaml
    oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role.yaml
    oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role_binding.yaml
    oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/scc.yaml
else
    oc create --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/charts_v1_mfoperator_crd.yaml
    oc create --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role.yaml
    oc create --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/role_binding.yaml
    oc create --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/mf/deploy/scc.yaml
fi

# Create/Switch Project back to MF namespace
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

echo -e "MobileFoundation preinstall completed."