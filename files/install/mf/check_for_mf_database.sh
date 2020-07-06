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

echo -e "${Bold}\nTest Mobile Foundation database connection.\n${Color_Off}"

DB_TYPE=DB2

POLL_COUNT=60

# Create/Switch Project for DB2
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE} mf

echo -e "\nDatabase host for test connection - ${Cyan}$_GEN_DB_HOSTNAME${Color_Off}"

printJobDebugMsg()
{
      echo -e "${Red}\nError during testing the database connection."
      
      oc -n "${_SYSGEN_MF_NAMESPACE}" logs -f mftestdb

      echo -e "\n\tRun the following commands to examine the status of the job for more details:"
      echo -e "\n\toc -n \"${_SYSGEN_MF_NAMESPACE}\" describe pod mftestdb"
      echo -e "\n\toc -n \"${_SYSGEN_MF_NAMESPACE}\" logs -f mftestdb"
      echo
      echo -e "\n\tAfter the problem is resolved, attempt to install again.${Color_Off}"
}

# Construct JDBC URL
SET_DB_TYPE=$(echo $DB_TYPE| tr '[:lower:]' '[:upper:]')

case $SET_DB_TYPE in
  "DB2") 
        JDBC_URL="jdbc:db2://${_GEN_DB_HOSTNAME}:${_GEN_DB_PORT}/${_GEN_DB_NAME}"; ;;
  *) 
        echo "${Cyan}Invalid / No input for \"db_type\". Setting to DB2${Color_Off}" ;
        DB_TYPE=DB2;
        JDBC_URL="jdbc:db2://${_GEN_DB_HOSTNAME}:${_GEN_DB_PORT}/${_GEN_DB_NAME}" ;;
esac

PULL_SECRET=mf-image-docker-pull-${_SYSGEN_MF_NAMESPACE}

echo -e "\nCreating a test connection pod within the namespace - ${_SYSGEN_MF_NAMESPACE} ..."

oc run mftestdb --image=${_SYSGEN_DOCKER_REGISTRY}/cp/mfpf-dbinit:${_GEN_IMG_TAG} \
            --env="POD_NAMESPACE=${_SYSGEN_MF_NAMESPACE}" \
            --overrides='{ "apiVersion": "v1", "spec": { "imagePullSecrets": [{"name": "'${PULL_SECRET}'"}] } }' \
            --restart=Never \
            --command -- java -Dij.driver=com.ibm.db2.jcc.DB2Driver \
             -Dij.dburl=${JDBC_URL} -Dij.user=${_GEN_DB_USERID// } \
             -Dij.password=${_GEN_DB_PASSWORD// } \
             -cp /opt/ibm/MobileFirst/mfpf-libs/mfp-ant-deployer.jar:/opt/ibm/MobileFirst/dbdrivers/db2jcc4.jar \
              com.ibm.worklight.config.helper.database.CheckDatabaseExistence db2
RC=$?

if [ $RC -ne 0 ]; then
    echo -e "${Red}\n\tMobile Foundation database test connection failure.${Color_Off}"  
    exit $RC
else
      for (( i=1; i<=$POLL_COUNT; i++ ))
      do
            echo -e "\nTesting connection to the Mobile Foundation database ($i/$POLL_COUNT) ..."
            POD_STATUS_MSG=$(oc get pod mftestdb --output="jsonpath={.status.phase}")

            if [ "$POD_STATUS_MSG" = "Succeeded" ]
            then
                  oc logs mftestdb | grep " exists."
                  if [ $? -eq 0 ]
                  then
                        echo -e "${Green}Database test connection successful.${Color_Off}"
                        sleep 2
                        echo -e "Cleaning up the database test connection pod ..."
                        oc delete pod mftestdb -n ${_SYSGEN_MF_NAMESPACE}
                  else
                        echo -e "${Red}Database test connection failed. Ensure database configuration deployment values are set correctly.${Color_Off}"
                        #oc delete --ignore-not-found pod mftestdb -n ${NAMESPACE}
                        printJobDebugMsg
                        exit 1
                  fi
                  break;
            elif [ "$POD_STATUS_MSG" = "Failed" ]
            then
                  echo -e "${Red}Database test connection job failed. Ensure database configuration deployment values are set correctly.${Color_Off}"
                  # oc delete --ignore-not-found pod mftestdb -n ${NAMESPACE}
                  printJobDebugMsg
                  exit 1
            else
                  STATUS_REASON=$(oc get pod mftestdb --output="jsonpath={.status.containerStatuses[].state.waiting.reason}")
                 
                  if [ "$STATUS_REASON" = "ImagePullBackOff" ] 
                  then
                         echo -e "${Red}Image Pull failed.${Color_Off}"
                        # oc delete --ignore-not-found pod mftestdb -n ${NAMESPACE}
                        printJobDebugMsg
                        exit 1   
                  fi

                  if [ "$STATUS_REASON" = "CrashLoopBackOff" ] 
                  then
                         echo -e "${Red}Pod Crashed.${Color_Off}"
                        # oc delete --ignore-not-found pod mftestdb -n ${NAMESPACE}
                        printJobDebugMsg
                        exit 1   
                  fi

                  if [ $i -eq ${POLL_COUNT} ]
                  then 
                        echo -e "${Red}Database test connection job failed. Ensure database configuration deployment values are set correctly.${Color_Off}"
                        # oc delete --ignore-not-found pod mftestdb -n ${NAMESPACE}
                        printJobDebugMsg
                        exit 1
                  fi
                  sleep 10
                  continue
            fi
      done
fi

echo -e "Test database connection completed."
