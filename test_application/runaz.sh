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
eval $(minikube -p minikube docker-env)

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

# return

echo "*********************************"
echo "*                               *"
echo "*     Running CURL Calls        *"
echo "*                               *"
echo "* Azure doesn't entertain       *"
echo "* the 307s.                     *"
echo "*********************************"



CURL_URI="https://donirwin.mids-w255.com/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"


CURL_URI="https://donirwin.mids-w255.com/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"


CURL_URI="https://donirwin.mids-w255.com/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"


CURL_URI="https://donirwin.mids-w255.com/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"


CURL_URI="https://donirwin.mids-w255.com/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"


CURL_URI="https://donirwin.mids-w255.com/health"

echo "About to call the following URI: ${CURL_URI}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "${CURL_URI}")
curl ${CURL_URI}
echo ""
echo "the return code is : ${return_code}"


echo "*********************************"
echo "*                               *"
echo "* Posts to predict -- should    *"
echo "* have 200 return codes         *"
echo "*********************************"

good_return_codes=0
bad_return_codes=0

eval_return () {
  my_code="$1"
  

if [ "$my_code" == "200" ]; then
    let "good_return_codes = good_return_codes+1"
else
    let "bad_return_codes = bad_return_codes+1"
fi

}

echo "*********************************"
echo "*                               *"
echo "* Posts to predict -- should    *"
echo "* have 200 return codes         *"
echo "*********************************"

#export REDIS_SERVER=localhost
#echo $REDIS_SERVER

#return

good_return_codes=0
bad_return_codes=0

eval_return () {
  my_code="$1"
  

if [ "$my_code" == "200" ]; then
    let "good_return_codes = good_return_codes+1"
else
    let "bad_return_codes = bad_return_codes+1"
fi

}

echo "*********************************"
echo "* Posts to predict -- should    *"
echo "* have 200 return codes         *"
echo "* We are doing 10 iterations    *"
echo "*********************************"


for i in {1..10}

do


return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' localhost:8000/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"


done


echo "*********************************"
echo "* END OF GOOD 200 ZONE          *"
echo "* Posts to predict -- should    *"
echo "* have 200 return codes         *"
echo "*********************************"

echo "*********************************"
echo "* BEGINNING OF BAD ZONE         *"
echo "* Posts to predict -- should    *"
echo "* NOT have 200 return codes     *"
echo "*********************************"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{"MedInc":8.3252,"HouseAge":41.0,"AveRooms":6.984126984126984,"AveBedrms":1.0238095238095237,"Population":322.0,"AveOccup":2.5555555555555554,"Latitude":37.88,"Longitude":-122.23, "fido" : "dido" }')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{"MedInc":8.3014,"HouseAge":21.0,"AveRooms":6.238137082601054,"AveBedrms":0.9718804920913884,"Population":2401.0,"AveOccup":2.109841827768014,"Latitude":37.86,"Longitude":-122.22 , "fido" : "dido" }')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{"MedInc":7.2574,"HouseAge":52.0,"AveRooms":8.288135593220339,"AveBedrms":1.073446327683616,"Population":496.0,"AveOccup":2.8022598870056497,"Latitude":"bozo","Longitude":-122.24 }')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{"MedInc":5.6431,"HouseAge":52.0,"AveRooms":5.8173515981735155,"AveBedrms":1.0730593607305936,"Population":558.0,"AveOccup":2.547945205479452,"Latitude":"jumk","Longitude":-122.25 }')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{"MedInc":3.8462,"HouseAge":52.0,"AveRooms":6.281853281853282,"AveBedrms":1.0810810810810811,"Population":565.0,"AveOccup":2.1814671814671813,"Latitude":37.85,"Longitude":"fido" }')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{"MedInc":4.0368,"HouseAge":52.0,"AveRooms":4.761658031088083,"AveBedrms":1.1036269430051813,"Population":413.0,"AveOccup":2.139896373056995,"Latitude":37.85,"Longitude":-122.25 , "fido" : "dido" }')

echo "*********************************"
echo "* END OF BAD ZONE               *"
echo "* Posts to predict -- should    *"
echo "* NOT have 200 return codes     *"
echo "*********************************"

echo "good_return_codes=${good_return_codes}"
echo "bad_return_codes=${bad_return_codes}"


echo "good_return_codes=${good_return_codes}"
echo "bad_return_codes=${bad_return_codes}"

echo "*********************************"
echo "*   End of Event Pitching      *"
echo "*********************************"

echo "*********************************"
echo "*   Expected                    *"
echo "*********************************"

echo "good_return_codes=250"
echo "bad_return_codes=5"

echo "*********************************"
echo "*   Actual                      *"
echo "*********************************"
echo "good_return_codes=${good_return_codes}"
echo "bad_return_codes=${bad_return_codes}"

    if [ $good_return_codes == "250" ]; then
        if [ $bad_return_codes == "5" ]; then

            echo "*********************************"
            echo "*   RETURN CODE COUNT           *"
            echo "*                               *"            
            echo "*   MATCH: Good                 *"
            echo "*                               *"
            echo "*********************************"

        fi

    else

            echo "*********************************"
            echo "*   RETURN CODE COUNT           *"
            echo "*                               *"            
            echo "*   MATCH: Bad                  *"
            echo "*                               *"
            echo "*********************************"
    fi


