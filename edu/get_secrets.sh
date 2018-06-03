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
    SA_NAME=zcp-system-sa-$USERNAME

    echo "zcp-system $SA_NAME token = "
    TOKEN_NAME=$(kubectl get sa -n zcp-system $SA_NAME -o jsonpath="{.secrets[0].name}")
    DECODED=$(kubectl get secret -n zcp-system $TOKEN_NAME -o jsonpath="{.data.token}" | base64 -D)
    echo $DECODED
    echo "\r\n"
  done

  echo "============== Setup Finished ===================="

fi
