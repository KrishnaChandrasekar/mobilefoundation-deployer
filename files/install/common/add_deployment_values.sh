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

echo -e "Adding the deployment values to the ${OPERATOR_NAME} customresource yaml files ... "

addMFconfig() 
{

	#  ingress/route specifics
	sed -i.bak "s|_IMG_PULLPOLICY_|${image_pullPolicy}|g" ${CR_YAML}
	sed -i.bak "s|_IMG_PULLSECRET_|mf-image-docker-pull-${_SYSGEN_MF_NAMESPACE}|g" ${CR_YAML}
	sed -i.bak "s|_INGRESS_HOSTNAME_|${ingress_subdomain_prefix}.${INGRESS_HOSTNAME}|g" ${CR_YAML}
	sed -i.bak "s|_INGRESS_SECRET_|${_GEN_INGRESS_TLS_SECRET_NAME}|g" ${CR_YAML}
	sed -i.bak "s|_SSL_PASSTHROUGH_|${ingress_sslPassThrough}|g" ${CR_YAML}
	sed -i.bak "s|_ENABLE_HTTPS_|${ingress_https}|g" ${CR_YAML}

	# DB placeholder substitution tasks
	sed -i.bak "s|_DB_TYPE_|DB2|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DB_HOST_|${_GEN_DB_HOSTNAME}|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DB_PORT_|${_GEN_DB_PORT}|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DB_NAME_|${_GEN_DB_NAME}|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DB_SECRET_|mobilefoundation-db-secret|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DB_SSL_ENABLE_|${db_ssl}|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DBADMIN_CRED_SECRET_|${db_adminCredentialsSecret}|g" ${CR_YAML}
	sed -i.bak "s|_MFPF_DB_DRIVER_PVC_|${db_driverPvc_for_oracle_or_mysql}|g" ${CR_YAML}

	# dbinit placeholder substitution tasks
	sed -i.bak "s|_DBINIT_ENABLE_|${dbinit_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_DBINIT_RR_CPU_|${dbinit_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_DBINIT_RR_MEM_|${dbinit_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_DBINIT_RL_CPU_|${dbinit_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_DBINIT_RL_MEM_|${dbinit_resources_limits_memory}|g" ${CR_YAML}

	# mfpserver placeholder substitution tasks
	sed -i.bak "s|_SERVER_ENABLE_|${mfpserver_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_CONSOLE_SECRET_|serverlogin|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_DB_SCHEMA_|${_GEN_SERVER_DB_SCHEMA}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_ADMINCLIENT_SECRET_|${mfpserver_adminClientSecret}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_PUSHCLIENT_SECRET_|${mfpserver_pushClientSecret}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_LUCLIENT_SECRET_|${mfpserver_liveupdateClientSecret}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_ICS_ADMINCLIENT_SECRET_ID_|${mfpserver_internalClientSecretDetails_adminClientSecretId}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_ICS_ADMINCLIENT_SECRET_PASSWORD_|${mfpserver_internalClientSecretDetails_adminClientSecretPassword}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_ICS_PUSHCLIENT_SECRETID_|${mfpserver_internalClientSecretDetails_pushClientSecretId}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_ICS_PUSHCLIENT_SECRET_PASSWORD_|${mfpserver_internalClientSecretDetails_pushClientSecretPassword}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_REPLICAS_|${mfpserver_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_AUTOSCALING_ENABLE_|${mfpserver_autoscaling_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_AUTOSCALING_MIN_|${mfpserver_autoscaling_min}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_AUTOSCALING_MAX_|${mfpserver_autoscaling_max}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_AUTOSCALING_TARGET_CPU_|${mfpserver_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_PDB_ENABLE_|${mfpserver_pdb_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_PDB_MIN_|${mfpserver_pdb_min}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_CUST_CONFIG_|${mfpserver_customConfiguration}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_KEYSTORE_SECRET_|${mfpserver_keystoreSecret}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_RR_CPU_|${mfpserver_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_RR_MEM_|${mfpserver_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_RL_CPU_|${mfpserver_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_SERVER_RL_MEM_|${mfpserver_resources_limits_memory}|g" ${CR_YAML}

	# mfppush placeholder substitution tasks
	sed -i.bak "s|_PUSH_ENABLE_|${mfppush_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_REPLICAS_|${mfppush_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_AUTOSCALING_ENABLE_|${mfppush_autoscaling_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_AUTOSCALING_MIN_|${mfppush_autoscaling_min}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_AUTOSCALING_MAX_|${mfppush_autoscaling_max}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_AUTOSCALING_TARGET_CPU_|${mfppush_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_PDB_ENABLE_|${mfppush_pdb_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_PDB_MIN_|${mfppush_pdb_min}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_CUST_CONFIG_|${mfppush_customConfiguration}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_KEYSTORE_SECRET_|${mfppush_keystoreSecret}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_RR_CPU_|${mfppush_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_RR_MEM_|${mfppush_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_RL_CPU_|${mfppush_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_PUSH_RL_MEM_|${mfppush_resources_limits_memory}|g" ${CR_YAML}

	# mfpliveupdate placeholder substitution tasks
	sed -i.bak "s|_LU_ENABLE_|${mfpliveupdate_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_LU_REPLICAS_|${mfpliveupdate_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_LU_DB_SCHEMA_|${_GEN_LU_DB_SCHEMA}|g" ${CR_YAML}
	sed -i.bak "s|_LU_AUTOSCALING_ENABLE_|${mfpliveupdate_autoscaling_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_LU_AUTOSCALING_MIN_|${mfpliveupdate_autoscaling_min}|g" ${CR_YAML}
	sed -i.bak "s|_LU_AUTOSCALING_MAX_|${mfpliveupdate_autoscaling_max}|g" ${CR_YAML}
	sed -i.bak "s|_LU_AUTOSCALING_TARGET_CPU_|${mfpliveupdate_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i.bak "s|_LU_PDB_ENABLE_|${mfpliveupdate_pdb_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_LU_PDB_MIN_|${mfpliveupdate_pdb_min}|g" ${CR_YAML}
	sed -i.bak "s|_LU_CUST_CONFIG_|${mfpliveupdate_customConfiguration}|g" ${CR_YAML}
	sed -i.bak "s|_LU_KEYSTORE_SECRET_|${mfpliveupdate_keystoreSecret}|g" ${CR_YAML}
	sed -i.bak "s|_LU_RR_CPU_|${mfpliveupdate_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_LU_RR_MEM_|${mfpliveupdate_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_LU_RL_CPU_|${mfpliveupdate_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_LU_RL_MEM_|${mfpliveupdate_resources_limits_memory}|g" ${CR_YAML}

	# mfpanalytics placeholder substitution tasks
	sed -i.bak "s|_ANALYTICS_ENABLE_|${mfpanalytics_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_CONSOLE_SECRET_|analyticslogin|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_REPLICAS_|${mfpanalytics_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_AUTOSCALING_ENABLE_|${mfpanalytics_autoscaling_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_AUTOSCALING_MIN_|${mfpanalytics_autoscaling_min}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_AUTOSCALING_MAX_|${mfpanalytics_autoscaling_max}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_AUTOSCALING_TARGET_CPU_|${mfpanalytics_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_PDB_ENABLE_|${mfpanalytics_pdb_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_ES_NAMESPACE_|${_GEN_ANALYTICS_ES_NAMESPACE}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_PDB_MIN_|${mfpanalytics_pdb_min}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_CUST_CONFIG_|${mfpanalytics_customConfiguration}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_KEYSTORE_SECRET_|${mfpanalytics_keystoreSecret}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_RR_CPU_|${mfpanalytics_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_RR_MEM_|${mfpanalytics_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_RL_CPU_|${mfpanalytics_resources_requests_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_ANALYTICS_RL_MEM_|${mfpanalytics_resources_requests_limits_memory}|g" ${CR_YAML}

	# mfpanalytics_recvr placeholder substitution tasks
	sed -i.bak "s|_RECVR_ENABLE_|${_GEN_RECVR_ENABLE}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_REPLICAS_|${mfpanalytics_recvr_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_AUTOSCALING_ENABLE_|${mfpanalytics_recvr_autoscaling_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_AUTOSCALING_MIN_|${mfpanalytics_recvr_autoscaling_min}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_AUTOSCALING_MAX_|${mfpanalytics_recvr_autoscaling_max}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_AUTOSCALING_TARGET_CPU_|${mfpanalytics_recvr_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_PDB_ENABLE_|${mfpanalytics_recvr_pdb_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_PDB_MIN_|${mfpanalytics_recvr_pdb_min}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_SECRET_|${mfpanalytics_recvr_analyticsRecvrSecret}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_CUST_CONFIG_|${mfpanalytics_recvr_customConfiguration}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_KEYSTORE_SECRET_|${mfpanalytics_recvr_keystoreSecret}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_RR_CPU_|${mfpanalytics_recvr_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_RR_MEM_|${mfpanalytics_recvr_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_RL_CPU_|${mfpanalytics_recvr_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_RECVR_RL_MEM_|${mfpanalytics_recvr_resources_limits_memory}|g" ${CR_YAML}

	# mfpappcenter placeholder substitution tasks
	sed -i.bak "s|_AC_ENABLE_|${mfpappcenter_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_AC_CONSOLE_SECRET_|appcntrlogin|g" ${CR_YAML}
	sed -i.bak "s|_AC_DB_SCHEMA_|${_GEN_AC_DB_SCHEMA}|g" ${CR_YAML}
	sed -i.bak "s|_AC_REPLICAS_|${mfpappcenter_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_AC_AUTOSCALING_ENABLE_|${mfpappcenter_autoscaling_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_AC_AUTOSCALING_MIN_|${mfpappcenter_autoscaling_min}|g" ${CR_YAML}
	sed -i.bak "s|_AC_AUTOSCALING_MAX_|${mfpappcenter_autoscaling_max}|g" ${CR_YAML}
	sed -i.bak "s|_AC_AUTOSCALING_TARGET_CPU_|${mfpappcenter_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i.bak "s|_AC_PDB_ENABLE_|${mfpappcenter_pdb_enabled}|g" ${CR_YAML}
	sed -i.bak "s|_AC_PDB_MIN_|${mfpappcenter_pdb_min}|g" ${CR_YAML}
	sed -i.bak "s|_AC_CUST_CONFIG_|${mfpappcenter_customConfiguration}|g" ${CR_YAML}
	sed -i.bak "s|_AC_KEYSTORE_SECRET_|${mfpappcenter_keystoreSecret}|g" ${CR_YAML}
	sed -i.bak "s|_AC_RR_CPU_|${mfpappcenter_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_AC_RR_MEM_|${mfpappcenter_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_AC_RL_CPU_|${mfpappcenter_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_AC_RL_MEM_|${mfpappcenter_resources_limits_memory}|g" ${CR_YAML}

	rm -rf ${CASE_FILES_TEMP_DIR}/components/mf/deploy/crds/*.yaml.bak
	rm -rf ${CASE_FILES_TEMP_DIR}/components/mf/deploy/*.yaml.bak
}

addESconfig()
{
	sed -i.bak "s|_IMG_PULLPOLICY_|${image_pullPolicy}|g" ${CR_YAML}
	sed -i.bak "s|_ES_IMG_PULLSECRET_|es-image-docker-pull-${_GEN_ES_NAMESPACE}|g" ${CR_YAML}
	sed -i.bak "s|_ES_PERSISTENCE_STORAGENAME_|${_GEN_ES_PERSISTENCE_STORAGECLASS_NAME}|g" ${CR_YAML}
	sed -i.bak "s|_ES_PERSISTENCE_CLAIMNAME_|${elasticsearch_persistence_claimName}|g" ${CR_YAML}
	sed -i.bak "s|_ES_PERSISTENCE_DISK_SIZE_|${elasticsearch_persistence_size}|g" ${CR_YAML}
	sed -i.bak "s|_ES_SHARDS_|${elasticsearch_shards}|g" ${CR_YAML}
	sed -i.bak "s|_ES_RPLICAS_PER_SHARD_|${elasticsearch_replicasPerShard}|g" ${CR_YAML}
	sed -i.bak "s|_ES_MASTER_REPLICAS_|${elasticsearch_master_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_ES_CLIENT_REPLICAS_|${elasticsearch_client_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_ES_DATA_REPLICAS_|${elasticsearch_data_replicas}|g" ${CR_YAML}
	sed -i.bak "s|_ES_DATA_RR_CPU_|${elasticsearch_data_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_ES_DATA_RR_MEM_|${elasticsearch_data_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_ES_DATA_RL_CPU_|${elasticsearch_data_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_ES_DATA_RL_MEM_|${elasticsearch_data_resources_limits_memory}|g" ${CR_YAML}
	sed -i.bak "s|_ES_RR_CPU_|${elasticsearch_master_resources_requests_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_ES_RR_MEM_|${elasticsearch_master_resources_requests_memory}|g" ${CR_YAML}
	sed -i.bak "s|_ES_RL_CPU_|${elasticsearch_master_resources_limits_cpu}|g" ${CR_YAML}
	sed -i.bak "s|_ES_RL_MEM_|${elasticsearch_master_resources_limits_memory}|g" ${CR_YAML}

	rm -rf ${CASE_FILES_TEMP_DIR}/components/es/deploy/crds/*.yaml.bak
	rm -rf ${CASE_FILES_TEMP_DIR}/components/es/deploy/*.yaml.bak

}

#
#    main
#

# copy from backup
CR_YAML="${CASE_FILES_TEMP_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr.yaml"

cp "${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr_template.yaml" "${CR_YAML}" 

# use ibm generated tls if user doesnt provide as deployment value
if [ "${ingress_secret}" = "" ]
then
	_GEN_INGRESS_TLS_SECRET_NAME=${INGRESS_SECRET_NAME}
else
	_GEN_INGRESS_TLS_SECRET_NAME=${ingress_secret}
fi

#
#  if analytics receiver is enabled without enabling analytics
#  disable the analytics receiver to prevent from unnecessary deployment
#  of the receiver component
#
if [ "${mfpanalytics_recvr_enabled}" = "true" ] && [ "${mfpanalytics_enabled}" = "false" ]
then
	echo -e "\n${Purple}Analytics receiver was enabled without analytics component. ${Color_Off}"
	echo -e "\n${Purple}Hence disabling analytics receiver component to proceed with deployment.${Color_Off}"
	_GEN_RECVR_ENABLE=false
else
	_GEN_RECVR_ENABLE=${mfpanalytics_recvr_enabled}
fi

# By mistake if end user adds both PVC name and storage class
# only PVC is considered to populate the CR yaml and deployment
# storage class is omitted
if [ "${db_persistence_storageClassName}" != "" ] && [ "${db_persistence_claimName}" != "" ]
then
	_GEN_DB_PERSISTENCE_STORAGECLASS_NAME=""
else	
	_GEN_DB_PERSISTENCE_STORAGECLASS_NAME=${db_persistence_storageClassName}
fi

if [ "${elasticsearch_persistence_storageClassName}" != "" ] && [ "${elasticsearch_persistence_claimname}" != "" ]
then
	_GEN_ES_PERSISTENCE_STORAGECLASS_NAME=""
else	
	_GEN_ES_PERSISTENCE_STORAGECLASS_NAME=${elasticsearch_persistence_storageClassName}
fi

if [ "${mfpanalytics_enabled}" = "false" ]
then
	export _GEN_ANALYTICS_ES_NAMESPACE=""
else
	export _GEN_ANALYTICS_ES_NAMESPACE="${_GEN_ES_NAMESPACE}"
fi

# replace image repo and tag value
sed -i.bak "s|_IMG_REPO_|${_GEN_IMG_REPO}|g" ${CR_YAML}
sed -i.bak "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CR_YAML}

if [ "$OPERATOR_NAME" = "es" ]
then
	if [ -f "${CASE_FILES_TEMP_DIR}/${OPERATOR_NAME}.txt" ]
	then
		export _GEN_ES_NAMESPACE=$(cat "${CASE_FILES_TEMP_DIR}/${OPERATOR_NAME}.txt")
	fi

    addESconfig
fi
addMFconfig
