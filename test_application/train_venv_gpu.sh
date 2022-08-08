#!/bin/bash

deactivate
 . setup_venv.sh
clear



while true; do

        echo "*********************************"
        echo "*                               *"
        echo "* The model directory is not    *"
        echo "* present.                      *"
        echo "*   Press \"D\" to download the   *"
        echo "*   Pre-trained model.          *"
        echo "*   Press \"T\" to train          *"
        echo "*   The model locally.          *"        
        echo "*                               *"        
        echo "*********************************"


    read -p "Do you wish to download or train? [D/T]:" dt
    case $dt in
        [Tt]* )  break;;
        [Dd]* ) gdown https://drive.google.com/drive/folders/1UHr84Wk0Om5igMP510QV4hmmRUAuslmK?usp=sharing -O ./distilbert-base-uncased-finetuned-sst2 --folder ;return;;
        * ) echo "Please answer \"d\" or \"t\".";;
    esac
done        





 is_cuda_available=$(python3 is_cuda_available.py)
 echo ${is_cuda_available}

if [ ! "$is_cuda_available"=="True" ]; then
  
        echo "*********************************"
        echo "*                               *"
        echo "* Torch is not able to          *"
        echo "*   see Nvidia cuda             *"
        echo "*   You can still the model on  *"
        echo "*   CPU, but it will be         *"
        echo "*    VERY SLOW                  *"
        echo "*                               *"        
        echo "*********************************"
        while true; do
            read -p "Do you still wish to run training [y/n]:" yn
            case $yn in
                [Yy]* ) export no_training=0; break;;
                [Nn]* ) export no_training=1;return;;
                * ) echo "Please answer \"y\" or \"n\".";;
            esac
        done        

 
fi

#clear the old directory
rm -rf ./distilbert-base-uncased-finetuned-sst2/

python ./trainer/train.py

#The latest directory will contain our files.
#latestdir=$(ls -td ./distilbert-base-uncased-finetuned-sst2/*/ | head -1)


#echo ${latestdir}

#copy the model into the root
#cp ${latestdir}* ./distilbert-base-uncased-finetuned-sst2/

#delete the checkpoints
rm -rf ./distilbert-base-uncased-finetuned-sst2/checkpoint*


export venv_activated=1

