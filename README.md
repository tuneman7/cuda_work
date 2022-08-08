#### U.C. Berkeley MIDS
#### Summer 2022
#### Training ML Models with NVIDIA GPU vs CPU
#### Don Irwin

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/cuda_splash.png?raw=true"
  alt="pod count"
  title="pod count"
  style="display: inline-block; margin: 0 auto; max-width: 300px">


#### Background:  

This project utilizes the DistilBertForSequenceClassification sentiment analysis model which is inside of the "glue" dataset.   

It downloads, or trains the model then serves it within a FASAPI container and runs K6 load testing against a minikube instance.

### Environmental requirements:   

Docker, Python3.10-venv, poetry, minikube, and K6.  The run-script should check dependencies and alert the user if any dependencies are missing.  

The project will run **without** the NVIDIA cuda tools, but it will be very slow, because it will use the CPU to train the model.  

### Getting GPU training to work:  -- be prepared to spend some hours on this.  

Some resources on this subject:  
https://tuneman7.github.io/cuda_notes.html  

* Have an NVIDIA graphics card or device which is compatible with NVIDIA’s CUDA package.  
* Install NVIDA drivers.  
* Install the CUDA packages / tools.  
* Test that pytorch can “see” the graphics card and do its work on it:  
. setup_venv.sh  
python3 is_cuda_available.py  
python3 get_cuda_info.py  

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/layers-between-ai-application-and-gpu.jpg?raw=true"
  alt="pod count"
  title="pod count"
  style="display: inline-block; margin: 0 auto; max-width: 300px">

### How to run project:   
git clone https://github.com/tuneman7/cuda_work  
cd cuda_work  
. run.sh  

Then follow prompts.  

### Test history:   

This has been tested on Linux Ubuntu 22.04 LTS only, with the following system specifications:   

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/system_information.png?raw=true"
  alt="system information"
  title="system information"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  
  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/graphic_card_information.png?raw=true"
  alt="graphic card information"
  title="graphic card information"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  




### Training Results CPU vs GPU Train Time:   

GPU training takes 17 minutes, CPU train time takes 7 hours.  
* We could perform 24 GPU trainings of the model in the time it takes the CPU to train the model once.

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/CPU_train_time.png?raw=true"
  alt="cpu train time"
  title="cpu train time"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  
  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/gpu_train_time.png?raw=true"
  alt="gpu train time"
  title="gpu train time"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  
### CPU Activity During CPU training and GPU Training:   

* CPU activity is very busy when training with CPU, much less so when training with GPU.

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/cpu_during_cpu_training.png?raw=true"
  alt="cpu during cpu training"
  title="cpu during cpu training"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  
  * CPU is not much utilized when training with the GPU.
  
  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/cpu_gpu_train_profile.png?raw=true"
  alt="cpu during gpu training"
  title="cpu during gpu training"
  style="display: inline-block; margin: 0 auto; max-width: 300px">


### NVIDIA GPU Activity During CPU Train and GPU Train:   

* GPU processing is negligible and memory is hardly used during CPU training.

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/nvidia_profile_CPU.png?raw=true"
  alt="Nvidia during CPU training"
  title="Nvidia during CPU training"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  
  * GPU processing is at 100% and python consumes memory during GPU training.
  
  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/nvidia_profile.png?raw=true"
  alt="Nvidia during GPU training"
  title="Nvidia during GPU training"
  style="display: inline-block; margin: 0 auto; max-width: 300px">


