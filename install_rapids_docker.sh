docker pull rapidsai/rapidsai-core:22.06-cuda11.5-runtime-ubuntu20.04-py3.9
docker run --gpus all --rm -it \
    --shm-size=1g --ulimit memlock=-1 \
    -p 8888:8888 -p 8787:8787 -p 8786:8786 \
    rapidsai/rapidsai-core:22.06-cuda11.5-runtime-ubuntu20.04-py3.9