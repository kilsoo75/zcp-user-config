#!/bin/sh
if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "This utility needs to two parameter in integer"
  echo "@usage: $ ./create.sh 1 10"
  exit 0
fi

start=$1
end=$2

if [ "$start" -gt "$end" ]
then
  echo "$start is bigger than $end"
else
  echo "============== Setup Starting ===================="

  for (( c=$start; c<=$end; c++ ))
  do  
    # Define Variables
    USERNAME=edu-0$c
    USER_NAMESPACE=ns-zcp-$USERNAME

    SA_NAME=zcp-system-sa-$USERNAME
    CRB_NAME=zcp-system-crb-$USERNAME
    RB_NAME=zcp-system-rb-$USERNAME

    LABEL_SYSTEM_USER=iam.cloudzcp.io/user=
    LABEL_SYSTEM_USERNAME=iam.cloudzcp.io/username=

    # ServiceAccount
    kubectl create serviceaccount $SA_NAME -n zcp-system
    kubectl label serviceaccount $SA_NAME $LABEL_SYSTEM_USER=true -n zcp-system
    kubectl label serviceaccount $SA_NAME $LABEL_SYSTEM_USERNAME=$USERNAME -n zcp-system

    # for kubeconfig ??
    SECRET_NAME=$(kubectl get serviceaccount -n zcp-system $SA_NAME -o jsonpath="{.secrets[0].name}")
    kubectl label secret $SECRET_NAME $LABEL_SYSTEM_USERNAME=$USERNAME -n zcp-system

    # Quota & LimitRange
    kubectl create namespace $USER_NAMESPACE
    kubectl create -f ./resourcequota.yaml -n $USER_NAMESPACE
    kubectl create -f ./mem-limit-range.yaml -n $USER_NAMESPACE
    kubectl create -f ./cpu-limit-range.yaml -n $USER_NAMESPACE
    
    # ClusterRoleBiding
    kubectl create clusterrolebinding $CRB_NAME --clusterrole=view --serviceaccount=zcp-system:$SA_NAME
    kubectl label clusterrolebinding $CRB_NAME $LABEL_SYSTEM_USERNAME=$USERNAME

    # RoleBinding
    kubectl create rolebinding $RB_NAME --clusterrole=admin --serviceaccount=zcp-system:$SA_NAME -n ns-zcp-$USERNAME
    kubectl label rolebinding $RB_NAME $LABEL_SYSTEM_USERNAME=$USERNAME -n $USER_NAMESPACE

    echo ".............."
  done

  echo "============== Setup Finished ===================="

fi
