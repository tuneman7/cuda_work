#!/bin/bash

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
echo "* We are doing 5 iterations   *"
echo "*********************************"


for i in {1..5}

do

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"
return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I love you","I hate you" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["this is good","This is bad" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["I am awake","I am tired" ]}')
eval_return "${return_code}"

return_code=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST -H 'Content-Type: application/json' https://donirwin.mids-w255.com/predict -d '{  "text": ["She looks healthy","She looks sick" ]}')
eval_return "${return_code}"


done



echo "*********************************"
echo "* END OF GOOD 200 ZONE          *"
echo "* Posts to predict -- should    *"
echo "* have 200 return codes         *"
echo "*********************************"

echo "good_return_codes=${good_return_codes}"
echo "bad_return_codes=${bad_return_codes}"

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

echo "*********************************"
echo "*   Expected                    *"
echo "*********************************"

echo "good_return_codes=120"
echo "bad_return_codes=5"

echo "*********************************"
echo "*   Actual                      *"
echo "*********************************"
echo "good_return_codes=${good_return_codes}"
echo "bad_return_codes=${bad_return_codes}"

    if [ $good_return_codes == "120" ]; then
        if [ $bad_return_codes == "5" ]; then

            echo "*********************************"
            echo "*   RETURN CODE COUNT           *"
            echo "*                               *"            
            echo "*   MATCH: Good                 *"
            echo "*                               *"
            echo "*********************************"
            export BAD_AZ_CURL_TESTING=0
        fi

    else

            echo "*********************************"
            echo "*   RETURN CODE COUNT           *"
            echo "*                               *"            
            echo "*   MATCH: Bad                  *"
            echo "*                               *"
            echo "*   Quitting program            *"
            echo "*********************************"
            export BAD_AZ_CURL_TESTING=1            
            return

    fi
