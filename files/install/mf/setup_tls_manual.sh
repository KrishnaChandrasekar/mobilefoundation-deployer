#!/bin/bash

CN_HOSTNAME=$1
INGRESS_SECRET_NAME=$2

openssl genrsa -out ${CASE_FILES_TEMP_DIR}/tls.key 2048 >/dev/null 2>&1
openssl req -new -x509 -key ${CASE_FILES_TEMP_DIR}/tls.key -out ${CASE_FILES_TEMP_DIR}/tls.cert -days 360 -subj /CN=${CN_HOSTNAME} >/dev/null 2>&1

echo -e "\nCreating ingress tls secret with generated tls.key and tls.cert ..."

oc create secret tls ${INGRESS_SECRET_NAME} --namespace=${_SYSGEN_MF_NAMESPACE} --cert=${CASE_FILES_TEMP_DIR}/tls.cert --key=${CASE_FILES_TEMP_DIR}/tls.key

if [ $? -ne 0 ]
then
    echo -e "${Red}\nIngress secret creation failed. ${Color_Off}"
    rm -rf ${CASE_FILES_TEMP_DIR}/tls.key ${CASE_FILES_TEMP_DIR}/tls.cert
    exit 1
fi



