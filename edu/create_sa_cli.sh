#!/bin/sh
if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "This utility needs to two parameter in integer"
  echo "@usage: $ ./create.sh 1 10"
  exit 0
fi

start=$1
end=$2

TENANT=zcp-dtlabs
API_SERVER_PORT=31986

if [ "$start" -gt "$end" ]
then
  echo "$start is bigger than $end"
else
  echo "============== Setup Starting ===================="

  for (( c=$start; c<=$end; c++ ))
  do
    kubectl config set-cluster --kubeconfig=./zcp-edu-0$c.conf $TENANT --server=https://169.56.69.242:$API_SERVER_PORT --certificate-authority=../ca-seo01-$TENANT.pem --embed-certs=true
    kubectl config set-context --kubeconfig=./zcp-edu-0$c.conf $TENANT --cluster=$TENANT
    TOKEN_NAME=$(kubectl get sa -n zcp-system zcp-edu-0$c -o jsonpath="{.secrets[0].name}")
    DECODED=$(kubectl get secret -n zcp-system $TOKEN_NAME -o jsonpath="{.data.token}" | base64 -D)
    kubectl config set-credentials --kubeconfig=./zcp-edu-0$c.conf zcp-edu-0$c@sk.com --token=$DECODED
    kubectl config set-context --kubeconfig=./zcp-edu-0$c.conf $TENANT --user=zcp-edu-0$c@sk.com --namespace=ns-zcp-edu-0$c
    kubectl config use-context --kubeconfig=./zcp-edu-0$c.conf $TENANT

    echo "...."
  done

  echo "============== Setup Finished ===================="
fi
