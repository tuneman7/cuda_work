#!/bin/bash

echo "*********************************"
echo "*  KILLING AND PROCESS          *"
echo "*  Using Port 8000              *"
echo "*                               *"
echo "*********************************"


. run_redis.sh

pid_to_kill=$(lsof -t -i :8000 -s TCP:LISTEN)

sudo kill ${pid_to_kill}

export REDIS_SERVER=localhost
echo $REDIS_SERVER

poetry run uvicorn mlapi.main:app --reload

docker stop redis
