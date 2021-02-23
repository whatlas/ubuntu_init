#

## 安装驱动

```bash

sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo update-initramfs -u
sudo reboot
sudo chmod a+x NVIDIA-*
sudo ./NVIDIA-* --no-opengl-files -a -s
```

## 安装git及其他

```bash

sudo apt-get remove thunderbird totem totem-common totem-plugins rhythmbox empathy brasero simple-scan gnome-majongg aisleriot gnome-mines cheese transmission-common gnome-sudoku onboard deja-dup libreoffice-common 

sudo apt install git vim build-essential python3-pip python3-opencv openssh-server unrar exfat-fuse htop terminator libssl-dev qt5-default

```
## 安裝cmake

```bash
cd cmake
./bootstrap --parallel=16 --qt-gui --prefix=/usr/local/cmake
make -j
sudo make install
```

## 安装python包

```bash

pip3 install pycuda numpy scipy termcolor jsonpickle demjson pandas shapely tqdm tabulate netifaces split urlpath pyquery marshmallow pycm
```

## 安装zsh，安装oh-my-zsh及插件

```bash

sudo apt install zsh

whereis zsh

sudo usermod -s PATH-TO-ZSH $(whoami)

sudo apt install powerline fonts-powerline

init 6

git clone https://github.com/ohmyzsh/ohmyzsh.git
cd ohmyzsh/tools
sh install.sh
cd -
rm -rf ohmyzsh

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

gedit ~/.zshrc
```

## 安装CUDA/CUDNN/TensorRT

```bash

sudo chmod a+x ./cuda-10.2**.run
sudo ./cuda-10.2**.run
cat /usr/local/cuda/version.txt

sudo echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.zshrc
sudo echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH" >> ~/.zshrc
source ~/.zshrc

tar -zxvf cudnn-****.tgz
cd cuda
sudo cp lib64/lib* /usr/local/cuda/lib64/
sudo cp include/cudnn.h /usr/local/cuda/include/
cat /usr/local/cuda/include/cudnn.h | grep CUDNN_MAJOR -A 2

tar -zxvf tensorrt-***.tar.gz
sudo echo "export LD_LIBRARY_PATH=/home/ecarx/Downloads/TensorRT-7.0.0.11/lib:$LD_LIBRARY_PATH" >> ~/.zshrc

pip3 install tensorrt-**/python/tensorrt-***.whl
pip3 install tensorrt-**/uff/uff-**.whl
pip3 install tensorrt-**/graphsurgeon/graphsurgeon**.whl

```

## 安装搜狗输入法

## 安装vscode

## 安装docker及nvidia-docker

```bash

curl https://get.docker.com | sh && sudo systemctl --now enable docker
sudo usermod -aG docker $(whoami)

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
sudo docker run --rm --gpus all nvidia/cuda:10.2-base nvidia-smi

```
