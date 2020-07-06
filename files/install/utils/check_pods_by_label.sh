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

echo -e "${Bold}\nChecking if the operator pod is available ...\n${Color_Off}"

check_pod_status() {
  
  for i in {1..30}; do
    echo -e "\nChecking $LABEL_VALUE-operator pod status ($i/30)..."
    PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath='{range .items[*]}{@.metadata.name}{":"}{@.status.phase}{"\n"}{end}')
    if [ $? -ne 0 ]; then
      continue
    fi

    if [ -z "$PODS" ]; then
      echo -e "${Red}The $LABEL_VALUE-operator pods are not created.${Color_Off}"
      exit 1
    fi

    for POD_ENTRY in $PODS; do
      POD=$(echo $POD_ENTRY | cut -d ':' -f1)
      STATUS=$(echo $POD_ENTRY | cut -d ':' -f2)
      MORE_STATUS=$(oc get pod ${POD} --output="jsonpath={.status.containerStatuses[].state.waiting.reason}")

      if [ "$MORE_STATUS" = "ImagePullBackOff" ] || [ "$MORE_STATUS" = "CrashLoopBackOff" ]; then
         return 1
      fi

      if [ "$STATUS" = "ErrImagePull" ] || [ "$STATUS" = "CrashLoopBackOff" ]; then
        return 1
      fi

      if [ "$STATUS" != "Running" ] && [ "$STATUS" != "Succeeded" ]; then
        if [ $i == 30 ]; then
          return 1
        fi
      fi

      if [ "$STATUS" = "Running" ] || [ "$STATUS" = "Succeeded" ]; then
        return 0
      fi

    done
    sleep 10
  done
}

wait_for_pod() {
  sleep 5
  PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath='{range .items[*]}{@.metadata.name}{":"}{@.status.phase}{"\n"}{end}')
  if [ -z "$PODS" ]; then
    echo -e "${Red}The $LABEL_VALUE operator pods are not created. Check logs for details.${Color_Off}"
    exit 1
  else
    if check_pod_status; then
      echo
      echo -e "\n${Green}All $LABEL_VALUE operator pods are running.${Color_Off}"
      exit 0
    else
      echo
      echo -e "${Red}The $LABEL_VALUE operator pods are not running. There might a problem that is preventing the pods from starting, or they might require additional time to start."
      echo
      echo -e "Run the following commands to examine the status of the pods:\n"
      for POD_ENTRY in $PODS; do
        POD=$(echo $POD_ENTRY | cut -d ':' -f1)
        echo "oc -n \"$NAMESPACE\" describe pod \"$POD\""
        echo "oc -n \"$NAMESPACE\" logs \"$POD\" --all-containers"
      done
      echo
      echo -e "\n\tAfter the problem is resolved, attempt to install again.${Color_Off}"
      exit 1
    fi
  fi

  echo -e "${Red}Timeout waiting for ${LABEL_VALUE}-operator pod to start.${Color_Off}"
  echo ""
  exit 1
}

wait_for_pod

oc logs -n ${NAMESPACE} --follow $POD
sleep 9
exit $(oc get pods -n ${NAMESPACE} ${POD} -o jsonpath="{.status.containerStatuses[0].state.terminated.exitCode}")
