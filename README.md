#### Summer 2022
#### Training ML Models with NVIDIA GPU vs CPU
#### Don Irwin


- [How to run project:](#how-to-run-project)
- [Background:](#background)
- [CPU and  GPU working together in AI frameworks:](#cpu-and--gpu-working-together-in-ai-frameworks)
- [Environmental requirements:](#environmental-requirements)
- [Getting GPU training to work:  -- be prepared to spend some hours on this.](#getting-gpu-training-to-work-----be-prepared-to-spend-some-hours-on-this)
- [Test history:](#test-history)
- [Training Results CPU vs GPU Train Time:](#training-results-cpu-vs-gpu-train-time)
- [CPU Activity During CPU training and GPU Training:](#cpu-activity-during-cpu-training-and-gpu-training)
- [NVIDIA GPU Activity During CPU Train and GPU Train:](#nvidia-gpu-activity-during-cpu-train-and-gpu-train)



  <a href="https://www.youtube.com/watch?v=GAvBgYGeKNM" target="https://www.youtube.com/watch?v=GAvBgYGeKNM"><img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/cuda_splash.png?raw=true"
  alt="video of thing"
  title="video of thing"
  style="display: inline-block; margin: 0 auto; max-width: 300px"></a>


### How to run project:  

View link below.  This has been tested on Linux Ubuntu 22.04 LTS only: 
- [Test history:](#test-history)   

```
git clone https://github.com/tuneman7/cuda_work  && cd cuda_work && . run.sh  
```  
OR  

```  
git clone https://github.com/tuneman7/cuda_work  
cd cuda_work  
. run.sh  
```

Then follow prompts.  


### Background:  

This project utilizes the DistilBertForSequenceClassification sentiment analysis model which is inside of the "glue" dataset.   

It downloads, or trains the model then serves it within a docker container with FASAPI, within a minikube cluster, that also contains a redis container,  and runs K6 load testing against a minikube instance.

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/the_pipeline.png?raw=true"
  alt="Pipeline Overview"
  title="Pipeline Overview"
  style="display: inline-block; margin: 0 auto; max-width: 250px">

### CPU and  GPU working together in AI frameworks:

CPUs have larger instruction sets, allowing them to “do more things” than a GPU.  However, GPUs generally contain thousands of cores, achieve higher parallelism, and are very good with matrix multiplication, utilized by machine learning, and neural net frameworks.  Often times the CPU acts as the “controller” off-loading tasks to the GPU then persisting or evaluating the results.


  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/cpu_vs_gpu.png?raw=true"
  alt="CPU VS GPU"
  title="CPU vs GPU"
  style="display: inline-block; margin: 0 auto; max-width: 250px">

### Environmental requirements:   

Docker, Python3.10-venv, poetry, minikube, and K6.  The run-script should check dependencies and alert the user if any dependencies are missing.  

The project will run **without** the NVIDIA cuda tools, but it will be very slow, because it will use the CPU to train the model.  

### Getting GPU training to work:  -- be prepared to spend some hours on this.  

Some resources on this subject:  
https://tuneman7.github.io/cuda_notes.html  

* Have an NVIDIA graphics card or device which is compatible with NVIDIA’s CUDA package.  
* Install NVIDA drivers.  
* Install the CUDA packages / tools.  
* Look at or adapt the following files: install_cuda.sh , nvidia_docker_install.sh
* Test that pytorch can “see” the graphics card and do its work on it:  
```
git clone https://github.com/tuneman7/cuda_work  && . ./cuda_work/test_python_cuda.sh
```
OR 
```
git clone https://github.com/tuneman7/cuda_work 
cd cuda_work
. test_python_cuda.sh  
```

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/layers-between-ai-application-and-gpu.jpg?raw=true"
  alt="pod count"
  title="pod count"
  style="display: inline-block; margin: 0 auto; max-width: 250px">

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

* CPU training time 7 hours.

  <img
  src="https://github.com/tuneman7/cuda_work/blob/main/images/CPU_train_time.png?raw=true"
  alt="cpu train time"
  title="cpu train time"
  style="display: inline-block; margin: 0 auto; max-width: 300px">
  
* GPY training time @ 17 minutes.
  
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


