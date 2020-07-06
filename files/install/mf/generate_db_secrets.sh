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

echo -e "${Bold}\nCreating Mobile Foundation database secret.${Color_Off}"

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

if [ "${mfpserver_enabled}" = "true" ] || [ "${mfppush_enabled}" = "true" ] || [ "${mfpliveupdate_enabled}" = "true" ] || [ "${mfpappcenter_enabled}" = "true" ]; then

	_GEN_DB_SECRET_NAME="mobilefoundation-db-secret"
	_GEN_DB_USERID_BASE64=$(echo -n "${_GEN_DB_USERID}" | base64)
	_GEN_DB_PASSWORD_BASE64=$(echo -n "${_GEN_DB_PASSWORD}" | base64)

	DB_SECRET_STRING="apiVersion: v1\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}data:\n"

	if [ "${mfpserver_enabled}" = "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_ADMIN_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_ADMIN_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_RUNTIME_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_RUNTIME_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	if [ "${mfppush_enabled}" = "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_PUSH_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_PUSH_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	if [ "${mfpliveupdate_enabled}" = "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_LIVEUPDATE_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_LIVEUPDATE_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	if [ "${mfpappcenter_enabled}" = "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_APPCNTR_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_APPCNTR_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	DB_SECRET_STRING="${DB_SECRET_STRING}kind: Secret\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}metadata:\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}  name: ${_GEN_DB_SECRET_NAME}\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}type: Opaque"

	echo -e "${DB_SECRET_STRING}" > ${CASE_FILES_TEMP_DIR}/${_GEN_DB_SECRET_NAME}.yaml

	oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_TEMP_DIR}/${_GEN_DB_SECRET_NAME}.yaml

	RC=$?

	if [ $RC -ne 0 ]; then
		echo -e "${Red}\nMobile Foundation database secret creation failure.${Color_Off}"
		exit $RC
	else
		echo -e "\nMobile Foundation database secret ($_GEN_DB_SECRET_NAME) created."
	fi

	rm -f ${CASE_FILES_TEMP_DIR}/${_GEN_DB_SECRET_NAME}.yaml

fi

echo -e "\nMobile Foundation DB secret creation complete."