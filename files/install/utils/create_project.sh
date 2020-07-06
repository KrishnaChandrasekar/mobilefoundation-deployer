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

CUR_DIR="$(cd $(dirname $0) && pwd)"

source $CUR_DIR/../utils/functions.sh

NAME=$1
OPERATOR_NAME=$2
switch_project "$NAME" "$OPERATOR_NAME"

