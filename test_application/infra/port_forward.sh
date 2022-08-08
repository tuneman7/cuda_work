#!/bin/bash

echo "kubectl port-forward -n w255 service/frontend 8000:8000 > output.txt &"

kubectl port-forward -n w255 service/frontend 8000:8000 > output.txt & 
