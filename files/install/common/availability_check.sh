#!/bin/bash
#                                                                 *
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
#                                                                 *

tick_unicode="\xE2\x9C\x94"

# print the readiness check return value
printReturnMsg() {
	RC=$1
	COMPONENT=$2
	if [ $RC -ne 0 ]; then
		echo -e "${Red}\n$2 readiness check failed.${Color_Off}"
		exit $RC
	else
		echo -e " ${Green}${tick_unicode} OK ${Color_Off}\n"
	fi
}

#
#  if analytics receiver is enabled without enabling analytics
#  disable the analytics receiver to prevent from unnecessary deployment
#  of the receiver component
#
if [ "${mfpanalytics_recvr_enabled}" = "true" ] && [ "${mfpanalytics_enabled}" = "false" ]
then
	_GEN_RECVR_ENABLE=false
else
	_GEN_RECVR_ENABLE=${mfpanalytics_recvr_enabled}
fi

checkMFReadiness()
{

	if [ "${mfpserver_enabled}" = "true" ]
	then	
		echo -e "\n${Cyan}Check Liveliness & Readiness of  Mobile Foundation server            ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_IMG_TAG},component=server ui
		RC=$?
		printReturnMsg $RC "Mobile Foundation Server"
	fi

	if [ "${mfppush_enabled}" = "true" ]
	then	
		echo -e "\n${Cyan}Check Liveliness & Readiness of Mobile Foundation Push              ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_IMG_TAG},component=push ui
		RC=$?
		printReturnMsg $RC "Mobile Foundation Push"
	fi

	if [ "${mfpliveupdate_enabled}" = "true" ]
	then	
		echo -e "\n${Cyan}Check Liveliness & Readiness of Mobile Foundation LiveUpdate          ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_IMG_TAG},component=liveupdate ui
		RC=$?
		printReturnMsg $RC "Mobile Foundation Liveupdate"
	fi

	if [ "${_GEN_RECVR_ENABLE}" = "true" ]
	then	
		echo -e "\n${Cyan}Check Liveliness & Readiness of Mobile Foundation Analytics Receiver     ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_IMG_TAG},component=analytics-recvr ui
		RC=$?
		printReturnMsg $RC "Mobile Foundation AnalyticsReceiver"
	fi

	if [ "${mfpanalytics_enabled}" = "true" ]
	then	
		echo -e "\n${Cyan}Check Liveliness & Readiness of Mobile Foundation Analytics        ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_IMG_TAG},component=analytics ui
		RC=$?
		printReturnMsg $RC "Mobile Foundation AnalyticsService"
	fi

	if [ "${mfpappcenter_enabled}" = "true" ]
	then	
		echo -e "\n${Cyan}Check Liveliness & Readiness of Mobile Foundation Application Center     ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_IMG_TAG},component=appcenter ui
		RC=$?
		printReturnMsg $RC appcenter
	fi

}

checkESReadiness()
{

	if [ "${mfpanalytics_enabled}" = "true" ]
	then
		echo -e "\n${Cyan}Check Liveliness & Readiness of Elasticsearch client             ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_ES_NAMESPACE} helm.sh/chart=ibm-es-prod-${_GEN_IMG_TAG},esnode=client backend
		RC=$?
		printReturnMsg $RC Elasticsearch-client

		echo -e "\n${Cyan}Check Liveliness & Readiness of Elasticsearch master             ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_ES_NAMESPACE} helm.sh/chart=ibm-es-prod-${_GEN_IMG_TAG},esnode=master backend
		RC=$?
		printReturnMsg $RC Elasticsearch-master

		echo -e "\n${Cyan}Check Liveliness & Readiness of Elasticsearch data service          ${Color_Off}"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_ES_NAMESPACE} helm.sh/chart=ibm-es-prod-${_GEN_IMG_TAG},esnode=data backend
		RC=$?
		printReturnMsg $RC Elasticsearch-data
	fi
}

#
# main
#

COMPONENT_NAME=$1

if [ "$COMPONENT_NAME" = "es" ]
then
	checkESReadiness "$COMPONENT_NAME"
fi

if [ "$COMPONENT_NAME" = "mf" ]
then
	checkMFReadiness "$COMPONENT_NAME"
fi
