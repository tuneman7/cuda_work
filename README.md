### U.C. Berkeley MIDS
### Summer 2022
### Training ML Models with NVIDIA GPU vs CPU


  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/cuda_splash.png?raw=true"
  alt="pod count"
  title="pod count"
  style="display: inline-block; margin: 0 auto; max-width: 300px">


#### Background:  

This project utilizies the DistilBertForSequenceClassification sentiment analysis model which is inside of the "glue" dataset.   

It downloads, or trains the model then serves it within a FASAPI container and runs K6 load testing against a minikube instance.

### Environmental requirements:  

Docker, Python3.10-venv, poetry, minikube, and K6.  The run-script should check dependencies and alert the user if any dependencies are missing.

### Test history:   

This has been tested on Linux Ubuntu 22.04 LTS only.




