#!/bin/bash

##This script only runs the environment in local docker 
##on the same network. ... Not using minikube.

export REDIS_SERVER=localhost

#  if [ "$EUID" -ne 0 ]; then
#    echo "Please run as root"
#    return
#  fi

IMAGE_NAME=w255_project_don_irwin_venv1
APP_NAME=w255_project_don_irwin_venv1
DOCKER_FILE=Dockerfile.255project_venv1

NET_NAME=w255
echo "docker stop redis"
docker stop redis
echo "docker rm redis"
docker rm redis

echo "docker network rm ${NET_NAME}"
docker network rm ${NET_NAME}

echo "docker network create rm ${NET_NAME} "
docker network create ${NET_NAME} 

sleep 2


#build docker from the docker file
echo "docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE}"
docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE} .
echo "run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}"
#docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME} sleep infinity
docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}


echo "**********************************"
echo "* RUNNING K6 WITHOUT CACHE       *"
echo "**********************************"

. run_k6_local.sh 

echo "docker run -d --name redis -p 6379:6379 redis --net ${NET_NAME}"
docker run -d --net ${NET_NAME} --name redis -p 6379:6379 redis
echo "docker stop ${APP_NAME}"
docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}


echo "**********************************"
echo "* RUNNING K6 WITH REDIS CACHE    *"
echo "**********************************"

. run_k6_local.sh 


read -p "Press any key to complete:"


docker stop redis
docker rm redis

echo "docker stop ${APP_NAME}"
docker stop ${APP_NAME}
echo "docker rm ${APP_NAME}"
docker rm ${APP_NAME}

echo "docker network rm ${NET_NAME}"
docker network rm ${NET_NAME}
