#!/bin/bash

IMAGE_NAME=project
APP_NAME=project
DOCKER_FILE=Dockerfile.255project
ACR_DOMAIN=w255mids.azurecr.io
TAG=$(git rev-parse --short HEAD)
IMAGE_PREFIX=donirwin
NAMESPACE=donirwin
IMAGE_FQDN="${ACR_DOMAIN}/${IMAGE_PREFIX}/${IMAGE_NAME}:${TAG}"


echo "*********************************"
echo "*                               *"
echo "* killing docker so context     *"
echo "* is cleared                    *"
echo "*********************************"

#sudo systemctl stop docker
#sudo systemctl start docker


echo "*********************************"
echo "*                               *"
echo "* Logging into azure            *"
echo "*                               *"
echo "*********************************"


az login --tenant berkeleydatasciw255.onmicrosoft.com

az account set --subscription="6baae99a-4d64-4071-bfac-c363e71984c3"

az aks get-credentials --name w255-aks --resource-group w255 --overwrite-existing

kubectl config use-context minikube

kubectl config use-context w255-aks

az acr login --name w255mids

echo "Point shell output to minikube docker"
echo "eval $(minikube -p minikube docker-env)"
#eval $(minikube -p minikube docker-env)

#build docker from the docker file
echo "docker build -t "${IMAGE_NAME}:${TAG}" -f ${DOCKER_FILE}"
docker build -t "${IMAGE_NAME}:${TAG}" -f ${DOCKER_FILE} .


docker tag "${IMAGE_NAME}:${TAG}" ${IMAGE_FQDN}
docker push ${IMAGE_FQDN}
docker pull ${IMAGE_FQDN}

echo "*********************************"
echo "*  STARTING                     *"
echo "* Pushing to prod Kubernetes    *"
echo "*                               *"
echo "*********************************"

#read -p "Press any key to resume ..."

sed "s/\[TAG\]/${TAG}/g" .k8s/overlays/prod/patch-deployment-project_copy.yaml > .k8s/overlays/prod/patch-deployment-project.yaml

#kubelogin convert-kubeconfig
kubectl delete -k .k8s/overlays/prod
kubectl kustomize .k8s/overlays/prod
kubectl apply -k .k8s/overlays/prod

echo "*********************************"
echo "*  CREATE:                      *"
echo "* certificates                  *"
echo "*                               *"
echo "*********************************"


kubectl --namespace istio-ingress get certificates ${NAMESPACE}-cert
kubectl --namespace istio-ingress get certificaterequests
kubectl --namespace istio-ingress get gateways ${NAMESPACE}-gateway 


echo "*********************************"
echo "*                               *"
echo "* Waiting for API to be ready   *"
echo "*                               *"
echo "*********************************"


finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "https://donirwin.mids-w255.com/health")
    if [ $health_status == "200" ]; then
        finished=true
        echo "*********************************"
        echo "*                               *"
        echo "*        API is ready           *"
        echo "*                               *"
        echo "*********************************"
    else
        finished=false
    fi
done
echo""
echo""


