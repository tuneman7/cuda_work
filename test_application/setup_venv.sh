deactivate
rm -rf ./myproj
python3 -m venv myproj
source ./myproj/bin/activate
. ir.sh

ipython kernel install --user --name=myproj

 . cuda_info.sh

