
define install_if_not
	@echo "Checking $(1)"
	if [ ! -f "`which $(1)`" ]; then \
	sudo apt install -y $(1); \
	fi
endef

all: stow cspell starship fonts zsh gitconfig

.PHONY: gitconfig
gitconfig: stow
	@echo "Initializing gitconfig"
	@stow gitconfig

.PHONY: cspell
cspell:
	@echo "adding custom cspell dictionary"
	@stow cspell

.PHONY: stow
stow:
	@echo "Initializing stow"
	@$(call install_if_not, stow)
	@stow -vt ~ stow

.PHONY: starship
starship:
	@echo "Installing starship"
	@if [ ! -f "`which starship`" ]; then \
	curl -fsSL https://starship.rs/install.sh | sh; \
	fi

.PHONY: zsh_dep
zsh_dep:
	@echo "Installing my zsh dependencies"
	@$(call install_if_not, fzf)
	@$(call install_if_not, lua5.3)
	@$(call install_if_not, zsh)

.PHONY: zsh
zsh: stow zsh_dep starship fonts
	@echo "Initializing zsh"
	@stow zsh

.PHONY: fonts
fonts: stow
	@echo "Initializing fonts"
	@stow fonts
	@fc-cache -vf

cmake:
	@echo "Updating CMake"
	git clone https://github.com/Kitware/CMake.git --depth 1
	@cd cmake
	@./bootstrap --parallel=`nproc` --prefix=~/.local --qt-gui
	@make -j`nproc`
	@make install

python:
	@echo "installing python packages"
	@python3 -m pip install --user -r requirements.txt
	@python3 -m pretty_errors

.PHONY: sys_pack
sys_pack:
	@echo "Installing system packages"
	@sudo apt update && sudo apt upgrade -y
	@sudo apt install -y \
	stow \
	git \
	vim \
	build-essential \
	python3-pip \
	openssh-server \
	unrar \
	tree \
	fontconfig \
	exfat-fuse \
	htop \
	chafa \
	libssl-dev
	@sudo apt autoclean
	@sudo apt autoremove

microsoft:
	@echo "installing Microsoft Edge and VSCode"
	@sudo apt update && sudo apt upgrade -y
	@sudo apt install apt-transport-https ca-certificates curl software-properties-common wget -y
	@sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg
	@echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
	@sudo apt update
	@sudo apt install microsoft-edge-stable
	@sudo snap install --classic code-insiders

.PHONY: docker
docker:
	@echo "Installing docker"
	curl https://get.docker.com | sh && sudo systemctl --now enable docker
	sudo usermod -aG docker $(whoami)
	newgrp docker

	distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
	&& curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
	&& curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

	@sudo apt-get update
	@sudo apt-get install -y nvidia-docker2
	@sudo systemctl restart docker
	@sudo docker run --rm --gpus all nvidia/cuda:11.6.2-devel-ubuntu20.04 nvidia-smi

