#!/bin/bash

deactivate
 . setup_venv.sh

rm -rf ./distilbert-base-uncased-finetuned-sst2/

python ./trainer/train.py

latestdir=$(ls -td ./distilbert-base-uncased-finetuned-sst2/*/ | head -1)


echo ${latestdir}

cp ${latestdir}* ./distilbert-base-uncased-finetuned-sst2/

rm -rf ./distilbert-base-uncased-finetuned-sst2/checkpoint*

deactivate
