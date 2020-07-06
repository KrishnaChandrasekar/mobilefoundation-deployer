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

echo -e "${Bold}\nInstall procedure starting ...\n${Color_Off}"

#  Following are to be used from the builtin ENV variables
export _SYSGEN_MF_NAMESPACE=${JOB_NAMESPACE}
export _GEN_ES_NAMESPACE=${elasticsearch_namespace:-mobilefoundation-es}

# db schema settings
export _GEN_SERVER_DB_SCHEMA=${mfpserver_db_schema:-MFPDATA}
export _GEN_LU_DB_SCHEMA=${mfpliveupdate_db_schema:-MFPLIVUPD}
export _GEN_AC_DB_SCHEMA=${mfpappcenter_db_schema:-APPCNTR}

export _GEN_DB_PORT=${db_port:-50000}
export _GEN_DB_NAME=${db_name:-BLUDB}
export _GEN_DB_USERID=${db_userid:-db2inst1}
export _GEN_DB_PASSWORD=${db_password:-db2inst1}

#  Mobile Foundation Image tag
export _GEN_IMG_TAG=${image_tag}

export _SYSGEN_DOCKER_REGISTRY=${DOCKER_REGISTRY}
export _SYSGEN_DOCKER_REGISTRY_USER=${DOCKER_REGISTRY_USER}
export _SYSGEN_DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD}

if [ "${DOCKER_REGISTRY}" = "cp.stg.icr.io" ] || [ "${DOCKER_REGISTRY}" = "cp.icr.io" ]
then
	export _GEN_IMG_REPO="${_SYSGEN_DOCKER_REGISTRY}/cp"
else
	export _GEN_IMG_REPO="${_SYSGEN_DOCKER_REGISTRY}/${JOB_NAMESPACE}"
fi

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

exitDeploymentOnFailure()
{
	RC=$1
	MSG=$2
	if [ $RC -ne 0 ]; then
        echo -e "${Red}${MSG}\nExiting ...\n\n${Color_Off}"
        exit $RC
    else
        echo -e "${BGreen}  OK${Color_Off}\n"
	fi
}

findExistingMFDeployments()
{
	echo 
	echo -e "${Bold}Locating existing Mobile Foundation deployments with the cluster ... ${Color_Off}"
	echo "Please wait."
	echo 
	
	ALL_PROJECTS=$(oc get projects -o jsonpath='{range .items[*]} {@.metadata.name}')

	ES_EXISTS="false"
	DB_EXISTS="false"

	for PROJECT_ENTRY in $ALL_PROJECTS; do
		
		if [[ ${PROJECT_ENTRY} == "openshift"* ]] || [[ ${PROJECT_ENTRY} == "kube-"* ]] || [[ ${PROJECT_ENTRY} == "ibm-"* ]] || [[ ${PROJECT_ENTRY} == "tigera-"* ]] || [[ ${PROJECT_ENTRY} == "calico"* ]] || [[ ${PROJECT_ENTRY} == "rook-"* ]]
		then 
			continue
		fi

		CREATED_BY=$(oc get namespace $PROJECT_ENTRY -o jsonpath='{.metadata.annotations.ibm\.com/created-by}')

		if [ "$CREATED_BY" = "MobileFoundation-cli-es-${_GEN_ES_NAMESPACE}" ]; then
			echo "Elasticsearch deployment found under namespace - ${PROJECT_ENTRY}"
			echo "$PROJECT_ENTRY" > ${CASE_FILES_TEMP_DIR}/es.txt
			ES_EXISTS=true
		fi

	done

	if [ "${mfpanalytics_enabled}" = "true" ] 
	then
		if [ "${ES_EXISTS}" = "false" ]
		then
			echo "No associated Elasticsearch deployment found under namespace - ${_GEN_ES_NAMESPACE}"
		fi
	fi

	echo -e "\nContinuing to deploy ...\n"
}

invokeESUninstallForUpdate()
{
	oc projects | grep ${ALREADY_DEPLOYED_ES_NAMESPACE} > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		# Undeploy the already installed ES
		echo "Elasticsearch deployment already exists in namespace - ${ALREADY_DEPLOYED_ES_NAMESPACE}."
		echo "New namespace entered to deploy the Elasticsearch is ${_GEN_ES_NAMESPACE}."
		echo 
		echo "Proceeding to undeploy the Elasticsearch installed under namespace - ${ALREADY_DEPLOYED_ES_NAMESPACE}."

		${CASE_FILES_DIR}/install/cleanup/pre_uninstall.sh es ${ALREADY_DEPLOYED_ES_NAMESPACE}

		# delete the ES project
		${CASE_FILES_DIR}/install/utils/delete_project.sh ${ALREADY_DEPLOYED_ES_NAMESPACE}
	fi
}

deletePreExistingES()
{
	ALREADY_DEPLOYED_ES_NAMESPACE=$(cat ${CASE_FILES_TEMP_DIR}/es.txt)

	# completely uninstall ES when analytics is disabled
	if [ "${mfpanalytics_enabled}" = "false" ] 
	then
		invokeESUninstallForUpdate
		return 0
	fi

	# Compare old namespace and new namespace for ES
	if [ "${ALREADY_DEPLOYED_ES_NAMESPACE}" != "${elasticsearch_namespace// }" ]
	then	
		if [ "${ALREADY_DEPLOYED_ES_NAMESPACE}" != "${_GEN_ES_NAMESPACE}" ]
		then
			invokeESUninstallForUpdate
		fi
	fi
}

#  Set image pull secret name
_GEN_MF_PULLSECRET=mf-image-docker-pull

#  list all the components enabled 
${CASE_FILES_DIR}/install/common/list_enabled_components.sh

# List all the user set deployment values
if [ "${install_trace_enabled}" = "true" ]
then
	${CASE_FILES_DIR}/install/common/list_all_deploymentValues.sh
fi

#  validate inputs
${CASE_FILES_DIR}/install/common/input_validations.sh
RC=$?
exitDeploymentOnFailure "$RC" " "

# Cleanup any pre-existing test connection pods
echo -e "\nCleanup any pre-existing test connection pod if exists."
oc delete --ignore-not-found pod mftestdb -n ${_SYSGEN_MF_NAMESPACE} > /dev/null 2>&1
RC=$?
exitDeploymentOnFailure "$RC" " "

# Check for the pre-existing Mobile Foundation deployments
findExistingMFDeployments

if [ -f "${CASE_FILES_TEMP_DIR}/es.txt" ]
then
	deletePreExistingES
fi

#  deploy es
if [ "${mfpanalytics_enabled}" = "true" ]
then

	echo -e "${Bold}\nDeploy Elasticsearch components\n${Color_Off}"

		# Attempt to check if CRD exists
	oc get crds esoperators.es.ibm.com  -n ${_GEN_ES_NAMESPACE} > /dev/null 2>&1
	ESRC=$?

	if [ $ESRC -ne 0 ]
	then
		#  deploy es operator
		${CASE_FILES_DIR}/install/es/es_preinstall.sh create
		RC=$?
		exitDeploymentOnFailure "$RC" " "

		${CASE_FILES_DIR}/install/common/deploy_operator.sh es ${_GEN_ES_NAMESPACE} es-image-docker-pull-${_GEN_ES_NAMESPACE}
		RC=$?
		exitDeploymentOnFailure "$RC" " "
	else
		echo -e "\nUser running the update of the existing deployment."
		${CASE_FILES_DIR}/install/es/es_preinstall.sh apply
		RC=$?
		exitDeploymentOnFailure "$RC" " "
		
		${CASE_FILES_DIR}/install/common/deploy_operator.sh es ${_GEN_ES_NAMESPACE} es-image-docker-pull-${_GEN_ES_NAMESPACE}
		RC=$?
		exitDeploymentOnFailure "$RC" " "
	fi

	${CASE_FILES_DIR}/install/common/operators_availability_check.sh es ${_GEN_ES_NAMESPACE} "Elasticsearch Operator"
	RC=$?
	exitDeploymentOnFailure "$RC" " "

	echo -e "${Bold}\nAdd deployment values for Elasticsearch\n${Color_Off}"

	#  Adding deployment values for ES
	${CASE_FILES_DIR}/install/common/add_deployment_values.sh es
	RC=$?
	exitDeploymentOnFailure "$RC" " "

	if [ "${install_trace_enabled}" = "true" ]
	then
		echo -e "\nFollowing is the charts_v1_esoperator_cr.yaml for deployment.\n"
		echo -e "\n************************************************************************************************\n"
		cat "${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/charts_v1_esoperator_cr.yaml"
		echo -e "\n***********************************************************************************************\n"
	fi

	# deploy ES CR
	${CASE_FILES_DIR}/install/common/deploy_cr.sh es ${_GEN_ES_NAMESPACE}
	RC=$?
	exitDeploymentOnFailure "$RC" " "

	echo -e "${Bold}\nChecking the availability of Elasticsearch\n${Color_Off}"

	#  Check ES pod/services availability
	${CASE_FILES_DIR}/install/common/availability_check.sh es
	RC=$?
	exitDeploymentOnFailure "$RC" " "
fi

echo -e "${Bold}\nDeploy Mobile Foundation components\n${Color_Off}"

# Setup TLS secret
${CASE_FILES_DIR}/install/mf/setup_ingress_tls_secret.sh

#  Generate DB secret
if [ "${mfpserver_enabled}" = "true" ] || [ "${mfpappcenter_enabled}" = "true" ]
then
	${CASE_FILES_DIR}/install/mf/generate_db_secrets.sh
	RC=$?
	exitDeploymentOnFailure "$RC" " "
fi

#  Create console login secret
${CASE_FILES_DIR}/install/common/generate_consolelogin_secrets.sh
RC=$?
exitDeploymentOnFailure "$RC" " "

# Get DB hostname
if [ "${mfpserver_enabled}" = "true" ] || [ "${mfpappcenter_enabled}" = "true" ] 
then
	export _GEN_DB_HOSTNAME=${db_host}
fi

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

_GEN_MF_IMG_PULLSECRET=mf-image-docker-pull-${_SYSGEN_MF_NAMESPACE}

#  create pull secret
echo -e "Creating image pull secret ($_GEN_MF_IMG_PULLSECRET) for Mobile Foundation ...\n"
oc create secret docker-registry ${_GEN_MF_IMG_PULLSECRET} -n ${_SYSGEN_MF_NAMESPACE} --docker-server=${_SYSGEN_DOCKER_REGISTRY} --docker-username=${_SYSGEN_DOCKER_REGISTRY_USER} --docker-password=${_SYSGEN_DOCKER_REGISTRY_PASSWORD} --dry-run -o yaml | oc apply -f -
oc secrets -n ${_SYSGEN_MF_NAMESPACE} link default ${_GEN_MF_IMG_PULLSECRET} --for=pull


#  check for db reachability/test connection
${CASE_FILES_DIR}/install/mf/check_for_mf_database.sh "${db_type}"
RC=$?
exitDeploymentOnFailure "$RC" " "

# Attempt to check if CRD exists
oc get crds mfoperators.mf.ibm.com  -n ${_SYSGEN_MF_NAMESPACE} > /dev/null 2>&1
MFRC=$?

if [ $MFRC -ne 0 ]
then
	#  mf preinstall
	${CASE_FILES_DIR}/install/mf/mf_preinstall.sh create
	RC=$?
	exitDeploymentOnFailure "$RC" " "
else
	echo -e "\nCustom Resource Definition - mfoperators.mf.ibm.com already exists in the namespace - ${_SYSGEN_MF_NAMESPACE}."
	${CASE_FILES_DIR}/install/mf/mf_preinstall.sh apply
	RC=$?
	exitDeploymentOnFailure "$RC" " "
fi

echo -e "\n${Bold}Checking if the mf-operator exists ... \n${Color_Off}"
COUNT_OPERATOR_POD=$(oc get pod -l name=mf-operator -n ${_SYSGEN_MF_NAMESPACE} --no-headers | wc -l)
if [ $? -eq 0 ]
then
	if [ ${COUNT_OPERATOR_POD} -eq 0 ]
	then
		echo -e "\nmf-operator doesn't exists. Proceeding to deploy the mf-operator ...\n"
		${CASE_FILES_DIR}/install/common/deploy_operator.sh mf ${_SYSGEN_MF_NAMESPACE} mf-image-docker-pull-${_SYSGEN_MF_NAMESPACE}
	else
		echo "Mobile Foundation Operator exists already in the namespace - ${_SYSGEN_MF_NAMESPACE}."
		echo "Continuing to check the availability of mf-operator ..."
	fi
else
	echo -e "\n${Red}Failed to get the available mf-operator pods.${Color_Off}"
	exit 1
fi

${CASE_FILES_DIR}/install/common/operators_availability_check.sh mf ${_SYSGEN_MF_NAMESPACE} "Mobile Foundation Operator"
RC=$?
exitDeploymentOnFailure "$RC" " "

echo -e "${Bold}\nAdd deployment values for Mobile Foundation\n${Color_Off}"
#  Adding deployment values for MF
${CASE_FILES_DIR}/install/common/add_deployment_values.sh mf
RC=$?
exitDeploymentOnFailure "$RC" " "

if [ "${install_trace_enabled}" = "true" ]
then
	echo -e "\nFollowing is the charts_v1_mfoperator_cr.yaml for deployment.\n"
	echo -e "\n************************************************************************************************\n"
	cat "${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/charts_v1_mfoperator_cr.yaml"
	echo -e "\n***********************************************************************************************\n"
fi

# deploy MF CR
${CASE_FILES_DIR}/install/common/deploy_cr.sh mf ${_SYSGEN_MF_NAMESPACE}
RC=$?
exitDeploymentOnFailure "$RC" " "

echo -e "${Bold}\nChecking the availability of Mobile Foundation services\n${Color_Off}"

#
#  Check MF services availability
#
${CASE_FILES_DIR}/install/common/availability_check.sh mf
RC=$?
exitDeploymentOnFailure "$RC" " "

#
#  Print routes
#
${CASE_FILES_DIR}/install/common/print_routes.sh