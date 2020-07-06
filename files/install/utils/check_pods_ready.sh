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

NAMESPACE=$1
LABEL_QUERY=$2
LABEL_VALUE=$3
COUNT=$4

POLL_COUNT=${COUNT:-60}
HALF_POLL_COUNT=$(expr $POLL_COUNT / 2)

COMPONENT=$(echo $LABEL_QUERY | cut -f3 -d"=")

check_pod_status() {

  for (( i=1; i<=$POLL_COUNT; i++ ))
  do
    echo -e "\nChecking $COMPONENT pod status ($i/$POLL_COUNT) ..."
    
    PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath="$JSONPATH")
    if [ $? -ne 0 ]; then
      continue
    fi

    # even after 20 retries if the pod entries are not created, exit the checks
    if [ $i -eq 20 ]; then    
      if [ -z "$PODS" ]; then
          echo 
          echo -e "${Red}The $COMPONENT pods are not created yet. Check the operator logs for details.${Color_Off}"
          echo 
          exit 1
      fi
    fi

    for POD_ENTRY in $PODS; do
      POD=$(echo $POD_ENTRY | cut -d ':' -f1)
      PHASE=$(echo $POD_ENTRY | cut -d ':' -f2)
      CONDITIONS=$(echo $POD_ENTRY | cut -d ':' -f3)

      MORE_STATUS=$(oc get pod ${POD} --output="jsonpath={.status.containerStatuses[].state.waiting.reason}")

      if [ "$STATUS" = "ErrImagePull" ] || [ "$STATUS" = "CrashLoopBackOff" ]; then
        if [ $i -eq 60 ]; then
            return 1
        fi
        return 1
      fi

      if [ "$MORE_STATUS" = "ImagePullBackOff" ] || [ "$MORE_STATUS" = "CrashLoopBackOff" ]; then
         return 1
      fi

      if [ "$STATUS" = "ErrImagePull" ] || [ "$STATUS" = "CrashLoopBackOff" ]; then
        return 1
      fi

      if [ "$PHASE" = "Pending" ]; then
        if [ $i -eq $HALF_POLL_COUNT ]; then
            return 1
        fi
        break
      fi

      if [ "$PHASE" = "Running" ]; then
        if [[ "$CONDITIONS" == *"Ready=True"* ]]; then
          return 0
        else
          if [ $i -eq 60 ]; then
              return 1
          fi
        fi
      fi

    done
    
    sleep 10

  done

}

wait_for_pod() {

  JSONPATH='{range .items[*]}{@.metadata.name}:{@.status.phase}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
  
  if check_pod_status; then
    echo -e "${Green}\n$COMPONENT component is running and ready.${Color_Off}"
    exit 0
  else
    echo
    echo -e "${Red}The $COMPONENT pods are not running. There might a problem that is preventing the pods from starting, or they might require additional time to start."
    echo
    echo -e "Run the following commands to examine the status of the pods:\n"
    for POD_ENTRY in $PODS; do
      POD=$(echo $POD_ENTRY | cut -d ':' -f1)
      echo "oc -n \"$NAMESPACE\" describe pod \"$POD\""
      echo "oc -n \"$NAMESPACE\" logs \"$POD\" --all-containers"
    done
    echo
    echo -e "Once the problem is resolved or the pods start running, re-run the installer to complete the installation process.${Color_Off}"
    exit 1
  fi

  PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath="$JSONPATH")

  if [ -z "$PODS" ]; then
    echo 
    echo -e "${Red}The $COMPONENT pods are not created. Check the operator logs for details.${Color_Off}"
    echo 
    exit 1
  fi

  echo 
  echo -e "${Red}Timeout waiting for $COMPONENT pod to be ready.${Color_Off}"
  echo
  exit 1
}

wait_for_pod

oc logs -n ${NAMESPACE} --follow $POD
sleep 9
exit $(oc get pods -n ${NAMESPACE} ${POD} -o jsonpath="{.status.containerStatuses[0].state.terminated.exitCode}")
