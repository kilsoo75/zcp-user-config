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
  echo "============== Cleanup Starting ===================="

  for (( c=$start; c<=$end; c++ ))
  do  
    # Define Variables
    USERNAME=edu-0$c
    USER_NAMESPACE=ns-zcp-$USERNAME

    SA_NAME=zcp-system-sa-$USERNAME
    CRB_NAME=zcp-system-crb-$USERNAME
    RB_NAME=zcp-system-rb-$USERNAME

    kubectl delete clusterrolebinding $CRB_NAME
    kubectl delete quota compute-resources -n $USER_NAMESPACE
    kubectl delete limitranges mem-limit-range -n $USER_NAMESPACE
    kubectl delete limitranges cpu-limit-range -n $USER_NAMESPACE
    kubectl delete namespace $USER_NAMESPACE
    kubectl delete serviceaccount $SA_NAME -n zcp-system
    echo "....."
  done

  echo "============== Cleanup Finished ===================="
fi
