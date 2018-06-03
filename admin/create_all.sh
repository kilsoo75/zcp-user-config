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
    USERNAME=admin-0$c
    USER_NAMESPACE=ns-zcp-$USERNAME

    SA_NAME=zcp-system-sa-$USERNAME
    CRB_NAME=zcp-system-crb-$USERNAME
    RB_NAME=zcp-system-rb-$USERNAME

    # ServiceAccount
    kubectl create serviceaccount $SA_NAME -n zcp-system
    kubectl label serviceaccount $SA_NAME zcp-system-user=yes -n zcp-system
    kubectl label serviceaccount $SA_NAME zcp-system-username=$USERNAME -n zcp-system

    # for kubeconfig ??
    SECRET_NAME=$(kubectl get serviceaccount -n zcp-system $SA_NAME -o jsonpath="{.secrets[0].name}")
    kubectl label secret $SECRET_NAME zcp-system-username=$USERNAME -n zcp-system

    # Quota & LimitRange
    kubectl create namespace $USER_NAMESPACE
    kubectl create -f ./resourcequota.yaml -n $USER_NAMESPACE
    kubectl create -f ./mem-limit-range.yaml -n $USER_NAMESPACE
    kubectl create -f ./cpu-limit-range.yaml -n $USER_NAMESPACE
    
    # ClusterRoleBiding
    kubectl create clusterrolebinding $CRB_NAME --clusterrole=cluster-admin --serviceaccount=zcp-system:$SA_NAME
    kubectl label clusterrolebinding $CRB_NAME zcp-system-username=$USERNAME

    # RoleBinding
    kubectl create rolebinding $RB_NAME --clusterrole=cluster-admin --serviceaccount=zcp-system:$SA_NAME -n ns-zcp-$USERNAME
    kubectl label rolebinding $RB_NAME zcp-system-username=$USERNAME -n $USER_NAMESPACE

    echo ".............."
  done

  echo "============== Setup Finished ===================="

fi