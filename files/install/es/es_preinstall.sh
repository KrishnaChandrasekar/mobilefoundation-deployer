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

echo -e "${Bold}\nStarting es_preinstall ...\n${Color_Off}"

MODE=$1

# Create/Switch Project for ES
${CASE_FILES_DIR}/install/utils/create_project.sh ${_GEN_ES_NAMESPACE} es

_GEN_ES_IMG_PULLSECRET=es-image-docker-pull-${_GEN_ES_NAMESPACE}

echo -e "Creating image pull secret ($_GEN_ES_IMG_PULLSECRET) for Elasticsearch ...\n"

#  create pull secret
oc create secret docker-registry ${_GEN_ES_IMG_PULLSECRET} -n ${_GEN_ES_NAMESPACE} --docker-server=${_SYSGEN_DOCKER_REGISTRY} --docker-username=${_SYSGEN_DOCKER_REGISTRY_USER} --docker-password=${_SYSGEN_DOCKER_REGISTRY_PASSWORD} --dry-run -o yaml | oc apply -f -
oc secrets -n ${_GEN_ES_NAMESPACE} link default ${_GEN_ES_IMG_PULLSECRET} --for=pull

mkdir -p ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds

cp ${CASE_FILES_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd_template.yaml ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml
cp ${CASE_FILES_DIR}/components/es/deploy/role_template.yaml ${CASE_FILES_TEMP_DIR}/components/es/deploy/role.yaml
cp ${CASE_FILES_DIR}/components/es/deploy/role_binding_template.yaml ${CASE_FILES_TEMP_DIR}/components/es/deploy/role_binding.yaml
cp ${CASE_FILES_DIR}/components/es/deploy/scc_template.yaml ${CASE_FILES_TEMP_DIR}/components/es/deploy/scc.yaml

sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/es/deploy/role.yaml
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/es/deploy/role_binding.yaml
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_TEMP_DIR}/components/es/deploy/scc.yaml
sed -i.bak "s|_ES_NAMESPACE_|${_GEN_ES_NAMESPACE}|g" ${CASE_FILES_TEMP_DIR}/components/es/deploy/role_binding.yaml

rm -rf ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/*.yaml.bak
rm -rf ${CASE_FILES_TEMP_DIR}/components/es/deploy/*.yaml.bak

if [ "$MODE" = "apply" ]
then
    oc apply --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml
    oc apply --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/role.yaml
    oc apply --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/role_binding.yaml
    oc apply --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/scc.yaml
else
    oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml
    oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/role.yaml
    oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/role_binding.yaml
    oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/components/es/deploy/scc.yaml
fi

# Create/Switch Project back to MF namespace
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

echo -e "Elasticsearch preinstall completed."