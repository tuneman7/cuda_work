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

docker stop redis
docker rm redis

echo "docker stop ${APP_NAME}"
docker stop ${APP_NAME}
echo "docker rm ${APP_NAME}"
docker rm ${APP_NAME}

echo "docker network rm ${NET_NAME}"
docker network rm ${NET_NAME}

echo "docker network create rm ${NET_NAME} "
docker network create ${NET_NAME} 

sleep 2


#build docker from the docker file
echo "docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE}"
#docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE} .

while true; do

        echo "*********************************"
        echo "*                               *"
        echo "* Do you wish to build the      *"
        echo "* docker image?                 *"
        echo "*   Press \"B\" build             *"
        echo "*   Press \"N\" use existing      *"
        echo "*   image                       *"        
        echo "*                               *"        
        echo "*********************************"


    read -p "Build or not? [B/N]:" bn
    case $bn in
        [Nn]* )  break;;
        [Bb]* ) docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE} . ; break;;
        * ) echo "Please answer \"b\" or \"n\".";;
    esac
done        



echo "run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}"
#docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME} sleep infinity

docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}

echo "*********************************"
echo "*                               *"
echo "*        WAITING. ....          *"
echo "*        API not ready          *"
echo "*                               *"
echo "*********************************"


finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/health")
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



echo "**********************************"
echo "* RUNNING K6 WITHOUT CACHE       *"
echo "**********************************"

. run_k6_local.sh 

echo "docker run -d --name redis -p 6379:6379 redis --net ${NET_NAME}"
docker run -d --net ${NET_NAME} --name redis -p 6379:6379 redis
docker stop ${APP_NAME}
docker rm ${APP_NAME}
sleep 5
docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME}

finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/health")
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
