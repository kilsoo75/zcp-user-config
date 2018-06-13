#!/bin/sh
if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "This utility needs to two parameter in integer"
  echo "@usage: $ ./create.sh 1 10"
  exit 0
fi

# set variable
. ../env.properties

start=$1
end=$2

if [ "$start" -gt "$end" ]
then
  echo "$start is bigger than $end"
else
  echo "============== Setup Starting ===================="
  mkdir -p ./kubeconfig

  for (( c=$start; c<=$end; c++ ))
  do
    # Definde Variables
    USERNAME=admin-0$c
    USER_NAMESPACE=ns-zcp-$USERNAME

    SA_NAME=zcp-system-sa-$USERNAME
    CONFIG_FILE_NAME=zcp-$USERNAME
    CREDENTIAL_NAME=zcp-$USERNAME@sk.com

    kubectl config set-cluster --kubeconfig=../kubeconfig/$CONFIG_FILE_NAME.conf $TENANT --server=$API_SERVER_ENDPOINT:$API_SERVER_PORT --certificate-authority=$CERTIFICATE_PATH/ca-seo01-$TENANT.pem --embed-certs=true
    kubectl config set-context --kubeconfig=../kubeconfig/$CONFIG_FILE_NAME.conf $TENANT --cluster=$TENANT

    TOKEN_NAME=$(kubectl get sa -n zcp-system $SA_NAME -o jsonpath="{.secrets[0].name}")
    DECODED=$(kubectl get secret -n zcp-system $TOKEN_NAME -o jsonpath="{.data.token}" | base64 -D)
    kubectl config set-credentials --kubeconfig=../kubeconfig/$CONFIG_FILE_NAME.conf $CREDENTIAL_NAME --token=$DECODED

    kubectl config set-context --kubeconfig=../kubeconfig/$CONFIG_FILE_NAME.conf $TENANT --user=$CREDENTIAL_NAME --namespace=$USER_NAMESPACE
    kubectl config use-context --kubeconfig=../kubeconfig/$CONFIG_FILE_NAME.conf $TENANT

    echo "...."
  done

  echo "============== Setup Finished ===================="
fi
