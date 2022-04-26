#

## 安装驱动

```bash
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo update-initramfs -u
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt update
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo reboot
```

## 安装git及其他

```bash

sudo apt-get remove thunderbird totem totem-common totem-plugins rhythmbox empathy brasero simple-scan gnome-majongg aisleriot gnome-mines cheese transmission-common gnome-sudoku onboard deja-dup libreoffice-common 
sudo apt autoremove

sudo apt install -y git vim build-essential python3-pip openssh-server unrar tree exfat-fuse htop terminator libssl-dev qt5-default zlib1g-dev pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libavresample-dev libdc1394-22-dev libeigen3-dev libgtk-3-dev libvtk7-qt-dev

```
## 安裝cmake

```bash
git clone https://github.com/Kitware/CMake.git
cd cmake
./bootstrap --parallel=`nproc` --qt-gui --prefix=/usr/local/cmake
make -j`nproc`
sudo make install
```

## 安装OpenCV（contrib）

```bash
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.5.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.5.5.zip
unzip opencv.zip
unzip opencv_contrib.zip
sudo cmake -S opencv-4.5.5 -B opencv-4.5.5/build -DBUILD_EXAMPLES=OFF -DBUILD_JAVA=OFF -DBUILD_TESTS=OFF -DBUILD_WEBP=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/opencv/ -DENABLE_CXX11=ON  -DOPENCV_ENABLE_NONFREE=ON -DOPENCV_EXTRA_MODULES_PATH=opencv_contrib-4.5.5/modules/ -DWITH_CUDA=ON -DWITH_GSTREAMER=OFF -DWITH_WEBP=OFF
sudo cmake --build opencv-4.5.5/build --target install -j`nproc`
```

## 安装python包

```bash

python3 -m pip install jupyter notebook pycuda numpy scipy termcolor jsonpickle demjson pandas shapely tqdm tabulate netifaces split urlpath pyquery marshmallow pycm rich pretty_errors
python3 -m pretty_errors
```
### 使用 gitup 管理多个 git 项目:

https://github.com/earwig/git-repo-updater

```bash
python3 -m pip install gitup
```

## 安装zsh，安装oh-my-zsh及插件

```bash

sudo apt install zsh

whereis zsh

sudo usermod -s PATH-TO-ZSH $(whoami)
chsh -s /usr/bin/zsh

init 6

git clone https://github.com/ohmyzsh/ohmyzsh.git
cd ohmyzsh/tools
sh install.sh
cd -
rm -rf ohmyzsh

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

omz theme set ys
```

## 安装 cheatsheet.sh

```bash
curl https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh
chmod +x /usr/local/bin/cht.sh
```

## 安装CUDA/CUDNN/TensorRT

```bash
VER=`lsb_release -r | awk '{print $2}' | awk -F. '{print $1$2}'`
sudo wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu$VER/x86_64/cuda-ubuntu$VER.pin
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu$VER/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu$VER/x86_64/ /"
sudo apt update 
sudo apt-get install libnvinfer8 libnvonnxparsers8 libnvparsers8 libnvinfer-plugin8
sudo apt-get install libnvinfer-dev libnvonnxparsers-dev libnvparsers-dev libnvinfer-plugin-dev
python3 -m pip install numpy
sudo apt-get install python3-libnvinfer

```

## 安装搜狗输入法

```bash

```

## 安装 vscode 和 edge 浏览器

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common wget -y
sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update
sudo apt install microsoft-edge-stable
sudo snap install --classic code

```

## 安装额外字体

Fira Code：
wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip

思源黑体：
wget https://github.com/adobe-fonts/source-han-sans/releases/download/2.004R/SourceHanSansCN.zip

## 安装docker及nvidia-docker

```bash

curl https://get.docker.com | sh && sudo systemctl --now enable docker
sudo usermod -aG docker $(whoami)
newgrp docker

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
sudo docker run --rm --gpus all nvidia/cuda:11.6.2-devel-ubuntu20.04 nvidia-smi

```
