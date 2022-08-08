#!/bin/bash

echo "**********************************"
echo "* CUDA Docker Work               *"
echo "**********************************"


#  if [ "$EUID" -ne 0 ]; then
#    echo "Please run as root"
#    return
#  fi

IMAGE_NAME=rapidsai/rapidsai-core:22.06-cuda11.5-runtime-ubuntu20.04-py3.9
APP_NAME=cuda_rapids
DOCKER_FILE=Dockerfile.rapids


echo "docker stop ${APP_NAME}"
docker stop ${APP_NAME}
echo "docker rm ${APP_NAME}"
docker rm ${APP_NAME}

#Output images to the LOCAL minicube dealio -- rather than the default.
#echo "Point shell output to minikube docker"
#echo "eval $(minikube -p minikube docker-env)"
#eval $(minikube -p minikube docker-env)

#build docker from the docker file
echo "docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE}"
docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE} .

docker pull ${IMAGE_NAME} 
docker run --gpus all --rm -it \
    --shm-size=1g --ulimit memlock=-1 \
    --name ${APP_NAME} \
    -p 8888:8888 -p 8787:8787 -p 8786:8786 \
    ${IMAGE_NAME} 



