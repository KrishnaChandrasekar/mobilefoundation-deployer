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

#  list the components enabled
printf "${Bold}\nComponents enabled for the deployment\n${Color_Off}"

tick_unicode="\xE2\x9C\x94"
gray_with_space="\e[90m "

printf "\nEnabled components are marked with ${Green}${tick_unicode}${Color_Off} symbol."

if [ "${mfpserver_enabled}" = "true" ]; then
	server_color="${Green}${tick_unicode}"
else
	server_color="${gray_with_space}"
fi

if [ "${mfppush_enabled}" = "true" ]; then
	push_color="${Green}${tick_unicode}"
else
	push_color="${gray_with_space}"
fi

if [ "${mfpliveupdate_enabled}" = "true" ]; then
	lu_color="${Green}${tick_unicode}"
else
	lu_color="${gray_with_space}"
fi

if [ "${mfpanalytics_enabled}" = "true" ]; then
	analytics_color="${Green}${tick_unicode}"
else
	analytics_color="${gray_with_space}"
fi

if [ "${mfpanalytics_recvr_enabled}" = "true" ]; then
	ar_color="${Green}${tick_unicode}"
else
	ar_color="${gray_with_space}"
fi

if [ "${mfpappcenter_enabled}" = "true" ]; then
	appcenter_color="${Green}${tick_unicode}"
else
	appcenter_color="${gray_with_space}"
fi

printf "\n"
printf "\n  ${server_color}Server${Color_Off}              ${push_color}Push Notifications${Color_Off}         ${lu_color}LiveUpdate${Color_Off}"
printf "\n  ${analytics_color}Analytics${Color_Off}           ${ar_color}Analytics Receiver${Color_Off}      "
printf "\n  ${appcenter_color}Application Center${Color_Off} "
printf "\n"

if [ "${install_trace_enabled}" = "true" ]
then
    printf "${Bold}\nOperators auto-enabled for the deployment\n${Color_Off}"
    [ "${mfpanalytics_enabled}" = "true" ] && printf " \n >    Elasticsearch Operator"
    printf " \n >    Mobile Foundation Operator"
    echo 
fi
