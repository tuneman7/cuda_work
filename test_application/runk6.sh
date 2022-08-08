#!/bin/bash


az login --tenant berkeleydatasciw255.onmicrosoft.com

az account set --subscription="6baae99a-4d64-4071-bfac-c363e71984c3"

az aks get-credentials --name w255-aks --resource-group w255 --overwrite-existing

kubectl config use-context minikube

kubectl config use-context w255-aks

az acr login --name w255mids

echo "*********************************"
echo "*                               *"
echo "* Spinning up port forwarding   *"
echo "*                               *"
echo "*********************************"

echo "*********************************"
echo "*                               *"
echo "* Kill existing port forwarder  *"
echo "*                               *"
echo "*********************************"

pid_to_kill=$(lsof -t -i :3000 -s TCP:LISTEN)

sudo kill ${pid_to_kill}

echo "kubectl port-forward -n prometheus svc/grafana 3000:3000"

kubectl port-forward -n prometheus svc/grafana 3000:3000 > port_forwarding_output.txt &

echo "*********************************"
echo "*                               *"
echo "* Press enter once you've gotten*"
echo "* through the Azure login       *"
echo "*                               *"
echo "*********************************"


read -p "Press any key to resume ..."

#kubectl port-forward -n prometheus svc/grafana 3000:3000 

echo "*********************************"
echo "*                               *"
echo "* Run k6 load testing           *"
echo "*                               *"
echo "*********************************"

    echo "k6 run load.js"
    k6 run load.js

