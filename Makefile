
all: stow cspell starship fonts zsh gitconfig

.PHONY: gitconfig
gitconfig: stow
	@echo "Initializing gitconfig"
	stow gitconfig

.PHONY: cspell
cspell:
	@echo "adding custom cspell dictionary"
	stow cspell

.PHONY: stow
stow:
	@echo "Initializing stow"
	stow -vt ~ stow

.PHONY: starship
starship:
	@echo "Installing starship"
	curl -fsSL https://starship.rs/install.sh | sh

.PHONY: zsh_dep
zsh_dep:
	@echo "Installing my zsh dependencies"
	sudo apt install -y fzf stow
	sudo apt install -y lua5.3
	sudo apt install -y zsh
	sudo usermod -s /usr/bin/zsh $(whoami)
	chsh -s /usr/bin/zsh

.PHONY: zsh
zsh: stow zsh_dep starship fonts
	@echo "Initializing zsh"
	stow zsh

.PHONY: fonts
fonts: stow
	@echo "Initializing fonts"
	stow fonts
	fc-cache -vf

cmake:
	@echo "Updating CMake"
	git clone https://github.com/Kitware/CMake.git --depth 1
	cd cmake
	./bootstrap --parallel=`nproc` --prefix=~/.local --qt-gui
	make -j`nproc`
	make install

python:
	@echo "installing python packages"
	python3 -m pip install -r requirements.txt
	python3 -m pretty_errors

.PHONY: sys_pack
sys_pack:
	@echo "Installing system packages"
	sudo apt update && sudo apt upgrade -y
	sudo apt install -y \
	git \
	vim \
	build-essential \
	python3-pip \
	openssh-server \
	unrar \
	tree \
	exfat-fuse \
	htop \
	libssl-dev \
	qt5-default \
	zlib1g-dev \
	pkg-config \
	libavcodec-dev \
	libavformat-dev \
	libavutil-dev \
	libswscale-dev \
	libavresample-dev \
	libdc1394-22-dev \
	libeigen3-dev \
	libgtk-3-dev \
	libvtk7-qt-dev
	sudo apt autoclean
	sudo apt autoremove

microsoft:
	@echo "installing Microsoft Edge and VSCode"
	sudo apt update && sudo apt upgrade -y
	sudo apt install apt-transport-https ca-certificates curl software-properties-common wget -y
	sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
	sudo apt update
	sudo apt install microsoft-edge-stable
	sudo snap install --classic code-insiders
