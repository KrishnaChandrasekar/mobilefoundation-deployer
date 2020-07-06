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

echo -e "${Bold}\nMobile Foundation Routes ...\n${Color_Off}"

echo -e "\nFollowing are routes of Mobile Foundation components that are deployed."

if [ "${mfpserver_enabled}" = "true" ]; then
	echo -e "\n\t\t\t${Bold}MOBILE FOUNDATION SERVER CONSOLE ${Color_Off}"
	MF_ROUTE=$(oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{"\n"}{end}' | grep 'mfpconsole')
	echo -e "\n${BBlue}HTTP  : ${Color_Off}http://${MF_ROUTE}"
	echo -e "\n${BBlue}HTTPS : ${Color_Off}https://${MF_ROUTE}"
fi

if [ "${mfpanalytics_enabled}" = "true" ]; then
	echo -e "\n\t\t\t${Bold}MOBILE FOUNDATION ANALYTICS CONSOLE ${Color_Off}"
	ANALYTICS_ROUTE=$(oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{"\n"}{end}' | grep 'analytics' | grep -v 'service' | grep -v 'receiver')
	echo -e "\n${BBlue}HTTP  : ${Color_Off}http://${ANALYTICS_ROUTE}"
	echo -e "\n${BBlue}HTTPS : ${Color_Off}https://${ANALYTICS_ROUTE}"
fi

if [ "${mfpappcenter_enabled}" = "true" ]; then
	echo -e "\n\t\t\t${Bold}MOBILE FOUNDATION APPCENTER CONSOLE ${Color_Off}"
	AC_ROUTE=$(oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{"\n"}{end}' | grep 'appcenterconsole')
	echo -e "\n${BBlue}HTTP  : ${Color_Off}http://${AC_ROUTE}"
	echo -e "\n${BBlue}HTTPS : ${Color_Off}https://${AC_ROUTE}"
fi

#
# Open the Mobile Foundation Server Console in the default console
#

OS_TYPE=$(uname) >/dev/null 2>&1

if [ "${OS_TYPE}" = "Darwin" ]
then
	if [ "${mfpserver_enabled}" = "true" ]; then
		open https://${MF_ROUTE} >/dev/null 2>&1
	fi

	if [ "${mfpappcenter_enabled}" = "true" ]; then
		open https://${AC_ROUTE} >/dev/null 2>&1
	fi
elif [ "${OS_TYPE}" = "Linux" ]
then
	if [ "${mfpserver_enabled}" = "true" ]; then
		xdg-open https://${MF_ROUTE} >/dev/null 2>&1
	fi

	if [ "${mfpappcenter_enabled}" = "true" ]; then
		xdg-open https://${AC_ROUTE} >/dev/null 2>&1
	fi
else
	if [ "${mfpserver_enabled}" = "true" ]; then
		start https://${MF_ROUTE} >/dev/null 2>&1
	fi

	if [ "${mfpappcenter_enabled}" = "true" ]; then
		start https://${AC_ROUTE} >/dev/null 2>&1
	fi
fi



