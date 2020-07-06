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

echo -e "${Bold}\nCreating Mobile Foundation Console Login secrets.${Color_Off}"

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

# create server login secret
if [ "${mfpserver_enabled}" = "true" ]; then

	_GEN_SERVER_CONSOLE_SECRET=serverlogin
	_GEN_SERVER_CONSOLE_USERID_BASE64=$(echo -n ${mfpserver_consoleUserid} | base64)
	_GEN_SERVER_CONSOLE_PASSWORD_BASE64=$(echo -n ${mfpserver_consolePassword} | base64)

echo -e "Creating the server console login secret ... \n"

	cat <<EOF | oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f -
apiVersion: v1
data:
  MFPF_ADMIN_USER: ${_GEN_SERVER_CONSOLE_USERID_BASE64}
  MFPF_ADMIN_PASSWORD: ${_GEN_SERVER_CONSOLE_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${_GEN_SERVER_CONSOLE_SECRET}
type: Opaque
EOF

fi

# create analytics login secret
if [ "${mfpanalytics_enabled}" = "true" ]; then

	_GEN_ANALYTICS_CONSOLE_SECRET=analyticslogin
	_GEN_ANALYTICS_CONSOLE_USERID_BASE64=$(echo -n ${mfpanalytics_consoleUserid} | base64)
	_GEN_ANALYTICS_CONSOLE_PASSWORD_BASE64=$(echo -n ${mfpanalytics_consolePassword} | base64)

echo -e "\nCreating the analytics console login secret ... \n"

	cat <<EOF | oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f -
apiVersion: v1
data:
  MFPF_ANALYTICS_ADMIN_USER: ${_GEN_ANALYTICS_CONSOLE_USERID_BASE64}
  MFPF_ANALYTICS_ADMIN_PASSWORD: ${_GEN_ANALYTICS_CONSOLE_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${_GEN_ANALYTICS_CONSOLE_SECRET}
type: Opaque
EOF

fi

# create appcenter login secret
if [ "${mfpappcenter_enabled}" = "true" ]; then

	_GEN_AC_CONSOLE_SECRET=appcntrlogin
	_GEN_APPCENTER_CONSOLE_USERID_BASE64=$(echo -n ${mfpappcenter_consoleUserid} | base64)
	_GEN_APPCENTER_CONSOLE_PASSWORD_BASE64=$(echo -n ${mfpappcenter_consolePassword} | base64)

echo -e "\nCreating the application center console login secret ... \n"

	cat <<EOF | oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f -
apiVersion: v1
data:
  MFPF_APPCNTR_ADMIN_USER: ${_GEN_APPCENTER_CONSOLE_USERID_BASE64}
  MFPF_APPCNTR_ADMIN_PASSWORD: ${_GEN_APPCENTER_CONSOLE_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${_GEN_AC_CONSOLE_SECRET}
type: Opaque
EOF

fi

echo -e "\nMobile Foundation console secrets created."