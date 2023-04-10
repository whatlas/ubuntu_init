.PHONY := all

opencv:
	@echo "Installing OpenCV"
	wget -O opencv.zip https://github.com/opencv/opencv/archive/4.6.0.zip
	wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.6.0.zip
	unzip opencv.zip
	unzip opencv_contrib.zip
	cmake -S opencv-4.6.0 -B opencv-4.6.0/build -DBUILD_JAVA=OFF -DBUILD_WEBP=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=~/opencv/ -DENABLE_CXX11=ON  -DOPENCV_ENABLE_NONFREE=ON -DOPENCV_EXTRA_MODULES_PATH=opencv_contrib-4.6.0/modules/ -DWITH_CUDA=ON
	cmake --build opencv-4.6.0/build --target install -j`nproc`
	rm -rf opencv.zip opencv_contrib.zip

stow:
	@echo "Initializing stow"
	stow -vt ~ stow

starship:
	@echo "Installing starship"
	curl -fsSL https://starship.rs/install.sh | sh

zsh: stow starship
	@echo "Initializing zsh"
	stow zsh

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
	python3 -m pip install jupyter notebook pycuda numpy scipy termcolor jsonpickle demjson pandas shapely tqdm tabulate netifaces split urlpath pyquery marshmallow pycm rich pretty_errors gitup
	python3 -m pretty_errors

microsoft:
	@echo "installing Microsoft Edge and VSCode"
	sudo apt update && sudo apt upgrade -y
	sudo apt install apt-transport-https ca-certificates curl software-properties-common wget -y
	sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
	sudo apt update
	sudo apt install microsoft-edge-stable
	sudo snap install --classic code-insiders
