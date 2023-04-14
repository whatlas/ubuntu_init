#

## sudo 相关

### 无密码

```bash
echo "`whoami` ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$USER-for-sudo-password"
chmod 440 /etc/sudoers.d/dont-prompt-$USER-for-sudo-password
```

### 增加用户sudo权限

```bash
echo "`whoami` ALL=(ALL) ALL" | sudo tee "/etc/sudoers.d/$USER-sudo"
chmod 440 /etc/sudoers.d/$USER-sudo
```

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

## 安装git及其他

```bash

make sys_pack

```
## 安裝cmake

```bash
make cmake
```

## 安装OpenCV & OpenCV_contrib

```bash
make zsh
install_opencv 4.6.0
```

## 安装python包

```bash
make python
```

## 安装zsh，使用stow进行配置

```bash

make zsh
init 6

```

## 安装 VSCode 和 Edge 浏览器

```bash
make microsoft
```

## 安装额外字体


```bash
make fonts
```

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
