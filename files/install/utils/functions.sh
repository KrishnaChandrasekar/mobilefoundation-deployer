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

switch_project() {
    local NAME=$1
    local OPERATOR_NAME=$2
    if oc project "$NAME" > /dev/null 2>&1; then
        echo -e "\nSwitched to \"$NAME\" project.\n"
    else
        oc new-project "$NAME" > /dev/null
        if [ "${NAME}" != "default" ]
        then 
            oc annotate ns "$NAME" --overwrite "ibm.com/created-by=MobileFoundation-cli-${OPERATOR_NAME}-${NAME}" > /dev/null
        fi

        echo -e "\nCreated \"$NAME\" project.\n"
    fi
}