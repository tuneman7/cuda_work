#!/bin/bash
#get out of a viritual environment if we are in one
deactivate
. check_deps.sh > output.txt


clear

echo "**********************************"
echo "* U.C. Berkeley MIDS W255        *"
echo "* Summer 2022                    *"
echo "* Instructor: James York Winegar *"
echo "* Student: Don Irwin             *"
echo "* Independent Training Exercise  *"
echo "**********************************"

echo "**********************************"
echo "* CHECKING ALL DEPENDENCIES      *"
echo "* Python Virtual Environments    *"
echo "* Poetry, Docker, K6, & Minikube *"
echo "**********************************"


  if [ "$all_dependencies" -ne 1 ]; then

        echo "**********************************"
        echo "* Not all depdencies were met    *"
        echo "* Please install dependencies    *"
        echo "* and try again.                 *"
        echo "**********************************"

        if [ "$k6_present" -ne 0 ]; then
            echo "K6 is not installed."
            echo "visit https://k6.io/docs/getting-started/installation/"
            echo "**********************************"
            export all_dependencies=0
        fi

        if [ "$python_venv" -ne 0 ]; then
            echo "Python Virtual Environments are not installed."
            export all_dependencies=0
        fi

        if [ "$docker_present" -ne 0 ]; then
            echo "Docker is not installed."
            echo "**********************************"
            export all_dependencies=0
        fi  

        if [ "$minikube_present" -ne 0 ]; then
            echo "Minikube is not installed."
            echo "visit https://minikube.sigs.k8s.io/docs/start/"
            echo "**********************************"
            export all_dependencies=0
        fi  

        if [ "$poetry_present" -ne 0 ]; then
            echo "Poetry is not installed."
            export all_dependencies=0
        fi  

        # if [ "$bozo_present" -ne 0 ]; then
        #     echo "Bozo not installed."
        #     export all_dependencies=0
        # fi 
        echo "**********************************"
        echo "**********************************"
        return
  fi

export REDIS_SERVER=localhost

#  if [ "$EUID" -ne 0 ]; then
#    echo "Please run as root"
#    return
#  fi

IMAGE_NAME=w255_project_don_irwin
APP_NAME=w255_project_don_irwin
DOCKER_FILE=Dockerfile.255project
#DOCKER_FILE=Dockerfile.255project_venv1

echo "*********************************"
echo "*                               *"
echo "* recycle redis and create      *"
echo "*   docker network              *"
echo "*   redis outside of minicube   *"
echo "*   is needed for testing       *"
echo "*                               *"
echo "*********************************"

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

echo "docker run -d --name redis -p 6379:6379 redis --net ${NET_NAME}"
docker run -d --net ${NET_NAME} --name redis -p 6379:6379 redis


echo "*********************************"
echo "*                               *"
echo "* Installing Dependencies       *"
echo "*   virtual environment         *"
echo "*                               *"
echo "*********************************"

DIRECTORY="./distilbert-base-uncased-finetuned-sst2/"

venv_activated=0

if [ ! -d "$DIRECTORY" ]; then
  . train_venv_gpu.sh
   venv_activated=1
fi


if [ $venv_activated == 0 ]; then
    . setup_venv.sh
fi


echo "*********************************"
echo "*                               *"
echo "* Running app locally poetry    *"
echo "*   pytest -vv -s               *"
echo "*                               *"
echo "*********************************"

pytest -vv -s
poetry_test=$?

    if [ $poetry_test != "0" ]; then
        finished=true
        echo "*********************************"
        echo "*                               *"
        echo "*        pytest failed          *"
        echo "*                               *"
        echo "*        exiting                *"
        echo "*                               *"
        echo "*********************************"
        return
    else
        finished=false
    fi

echo "*********************************"
echo "*  FINISHED                     *"
echo "* Running app locally poetry    *"
echo "*   poetry run pytest -vv -s    *"
echo "*                               *"
echo "*********************************"

echo "*********************************"
echo "*  killing the virtual env      *"
echo "* so it does not get copied     *"
echo "*   to the container            *"
echo "*                               *"
echo "*********************************"

deactivate
rm -rf ./myproj

echo "*********************************"
echo "*  run a poetry install         *"
echo "*                               *"
echo "*********************************"

poetry install

echo "*********************************"
echo "*  STARTING                     *"
echo "* Docker stopping and rebuild   *"
echo "*                               *"
echo "*********************************"

#now that we're done with poetry, let's take down Redis
#before redirecting to minikube
NET_NAME=w255
echo "docker stop redis"
docker stop redis
echo "docker rm redis"
docker rm redis

echo "docker network rm ${NET_NAME}"
docker network rm ${NET_NAME}


echo "docker stop ${APP_NAME}"
docker stop ${APP_NAME}
echo "docker rm ${APP_NAME}"
docker rm ${APP_NAME}

echo "*********************************"
echo "*                               *"
echo "* Recycle kubernetes            *"
echo "*                               *"
echo "*********************************"

minikube stop

minikube start --kubernetes-version=v1.22.6 --memory 8192 --cpus 4

sleep 1

echo "*********************************"
echo "*                               *"
echo "* finished recycle k8           *"
echo "*                               *"
echo "*********************************"


#Output images to the LOCAL minicube dealio -- rather than the default.
echo "Point shell output to minikube docker"
echo "eval $(minikube -p minikube docker-env)"
eval $(minikube -p minikube docker-env)

#build docker from the docker file
echo "docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE}"
docker build -t ${IMAGE_NAME} -f ${DOCKER_FILE} .

#echo "docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME} "
#docker run -d --net ${NET_NAME} --name ${APP_NAME} -p 8000:8000 ${IMAGE_NAME} 


cd ./infra
. delete_deployments.sh
sleep 1
my_all_pods=$(kubectl get pods --all-namespaces| wc -l)
. apply_deployments.sh
cd ./../
my_all_pods_after_deploy=$(kubectl get pods --all-namespaces| wc -l)

echo my_all_pods=$my_all_pods


while [ $my_all_pods_after_deploy -le $my_all_pods ]; do
    my_all_pods_after_deploy=$(kubectl get pods --all-namespaces| wc -l)
    #echo my_all_pods=$my_all_pods
    #echo my_all_pods_after_deploy=$my_all_pods_after_deploy
done
echo my_all_pods=$my_all_pods
echo my_all_pods_after_deploy=$my_all_pods_after_deploy

#make sure we have more pods AFTER the scripts than before.

echo "*********************************"
echo "*  ENDING                       *"
echo "* Docker stopping and rebuild   *"
echo "*                               *"
echo "*********************************"

echo "**********************************"
echo "*  STARTING                      *"
echo "* port forwarding                *"
echo "*                                *"
echo "* Make sure all pods are running *"
echo "* Before issuing port forwarding *"
echo "*                                *".
echo "**********************************"

echo $PWD

my_all_pods=$(kubectl get pods --all-namespaces| wc -l)
echo $my_all_pods
running_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Running| wc -l)
echo $running_pods
while [ $running_pods -le $my_all_pods ]; do
    my_all_pods=$(kubectl get pods --all-namespaces| wc -l)
    running_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Running| wc -l)
    let "running_pods = running_pods+1"
done
sleep 1

echo "*********************************"
echo "*  KILLING ANY PROCESS          *"
echo "*  Using Port 8000              *"
echo "*                               *"
echo "*********************************"

pid_to_kill=$(lsof -t -i :8000 -s TCP:LISTEN)

  if [ "$pid_to_kill" -ne 0 ]; then
    sudo kill ${pid_to_kill}
  fi




echo "kubectl port-forward -n w255 service/frontend 8000:8000 > output.txt &"
kubectl port-forward -n w255 service/frontend 8000:8000 > output.txt & 

echo "kubectl port-forward -n w255 service/redis 6379:6379 > output_redis.txt & "
kubectl port-forward -n w255 service/redis 6379:6379 > output_redis.txt & 

sleep 1
echo "*********************************"
echo "*  ENDING                       *"
echo "* port forwarding               *"
echo "*                               *"
echo "*********************************"

sleep 1

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


echo "*********************************"
echo "*                               *"
echo "*     Running CURL Calls        *"
echo "*                               *"
echo "*  Note that FASTAPI uses 307   *"
echo "*  internal redirects for its   *"
echo "*  query string parsing unless  *"
echo "*  the request is formed line   *"
echo "*     /hello/?name=Don          *"
echo "*                               *"
echo "*********************************"


CURL_URI="http://localhost:8000/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"
CURL_URI="http://localhost:8000/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"
CURL_URI="http://localhost:8000/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"

echo "*********************************"
echo "*  RUN LOAD TEST AGAINST        *"
echo "* minikube                      *"
echo "*                               *"
echo "*                               *"
echo "*********************************"

k6 run load_local.js

echo "*********************************"
echo "*  KILLING                      *"
echo "* Docker stopping and remove    *"
echo "*                               *"
echo "*                               *"
echo "*********************************"


echo "docker stop ${APP_NAME}"
docker stop ${APP_NAME}
echo "docker rm ${APP_NAME}"
docker rm ${APP_NAME}
cd ./infra
. delete_deployments.sh
cd ./../

echo "*******************************************************"
echo "*                                                     *"
echo "* COMPLETE K6 TESTING                                 *"
echo "*                                                     *"
echo "*******************************************************"

echo "*******************************************************"
echo "*                                                     *"
echo "* Minikube stop and unset variables                   *"
echo "*                                                     *"
echo "*******************************************************"


minikube stop

unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME

deactivate
rm -rf ./myproj
