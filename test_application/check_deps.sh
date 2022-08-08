#check viritual environments:

python3 -m venv testing > /dev/null
export python_venv=$?
rm -rf testing
docker version > /dev/null
export docker_present=$?
minikube > /dev/null
export minikube_present=$?
k6 > /dev/null
export k6_present=$?

all_dependencies=1


  if [ "$k6_present" -ne 0 ]; then
    echo "K6 is not installed."
    export all_dependencies=0
  fi

  if [ "$python_venv" -ne 0 ]; then
    echo "Python Virtual Environments are not installed."
    export all_dependencies=0
  fi

  if [ "$docker_present" -ne 0 ]; then
    echo "Docker is not installed."
    export all_dependencies=0
  fi  

  if [ "$minikube_present" -ne 0 ]; then
    echo "Minikube is not installed."
    export all_dependencies=0
  fi  

#     bozo
#     bozo_present=$?

#   if [ "$bozo_present" -ne 0 ]; then
#     echo "Bozo not installed."
#     export all_dependencies=0
#   fi  

