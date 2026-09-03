SHELL := /bin/sh
OS := $(shell uname -s)
HOME_DIR := $(HOME)
DOTFILES_DIR := dotfiles
BREWFILE := Brewfile
PYTHON_ENV := $(HOME_DIR)/.local/share/ubuntu-init/venv

ifeq ($(OS),Darwin)
PLATFORM := macos
CPU_COUNT := $(shell sysctl -n hw.logicalcpu 2>/dev/null || echo 1)
STOW_PLATFORM_FLAGS := --ignore='^\.local/share/fonts'
else ifeq ($(OS),Linux)
PLATFORM := linux
CPU_COUNT := $(shell nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
STOW_PLATFORM_FLAGS :=
else
$(error Unsupported operating system: $(OS))
endif

.PHONY: all bootstrap deps packages dotfiles fonts python cmake llvm opencv microsoft docker doctor validate help

all: bootstrap

bootstrap:
	@$(MAKE) --no-print-directory packages
	@$(MAKE) --no-print-directory dotfiles
	@$(MAKE) --no-print-directory python
	@echo "Bootstrap completed for $(PLATFORM)"

help:
	@printf '%s\n' \
		'make bootstrap  Install packages, dotfiles, fonts, and Python tools' \
		'make packages   Install platform packages (Homebrew on macOS, apt on Linux)' \
		'make dotfiles   Deploy dotfiles with GNU Stow and install fonts' \
		'make python     Install Python packages for the current platform' \
		'make cmake      Install CMake for the current platform' \
		'make llvm       Install LLVM for the current platform' \
		'make opencv     Install OpenCV for the current platform' \
		'make microsoft  Install VS Code and Microsoft Edge' \
		'make docker     Install Docker runtime for the current platform' \
		'make doctor     Check required platform commands' \
		'make validate   Run non-destructive repository checks'

# Backward-compatible alias.
deps: packages

packages:
ifeq ($(OS),Darwin)
	@command -v brew >/dev/null 2>&1 || { echo "Homebrew is required: https://brew.sh" >&2; exit 1; }
	@test -w "$$(brew --cellar)" || { echo "Homebrew Cellar is not writable: $$(brew --cellar)" >&2; echo "Repair its ownership before installing; do not run brew with sudo." >&2; exit 1; }
	HOMEBREW_BUNDLE_FILE="$(abspath $(BREWFILE))" brew bundle install
else
	@command -v apt >/dev/null 2>&1 || { echo "Linux package installation currently supports Debian/Ubuntu (apt) only." >&2; exit 1; }
	@echo "Installing Ubuntu system packages"
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y \
		stow git vim zsh build-essential python3-pip python3-venv openssh-server unrar tree \
		fontconfig exfat-fuse htop chafa libssl-dev cmake ninja-build clangd
	sudo apt autoclean
	sudo apt autoremove -y
endif

# Backward-compatible Ubuntu target.
sys_pack: packages

dotfiles:
	@command -v stow >/dev/null 2>&1 || { echo "GNU Stow is required; run 'make packages' first." >&2; exit 1; }
	@echo "Deploying dotfiles"
	stow -R -v --target="$(HOME_DIR)" --no-folding $(STOW_PLATFORM_FLAGS) "$(DOTFILES_DIR)"
	@$(MAKE) --no-print-directory fonts

fonts:
ifeq ($(OS),Darwin)
	@echo "Installing fonts into $(HOME_DIR)/Library/Fonts"
	@mkdir -p "$(HOME_DIR)/Library/Fonts"
	@find "$(DOTFILES_DIR)/.local/share/fonts" -type f \( -name '*.ttf' -o -name '*.otf' \) \
		-exec cp -f {} "$(HOME_DIR)/Library/Fonts/" \;
else
	@command -v fc-cache >/dev/null 2>&1 || { echo "fontconfig is required; run 'make packages' first." >&2; exit 1; }
	fc-cache -f
endif

python:
	@PYTHON=python3; \
	if [ "$(OS)" = Darwin ]; then \
		if command -v python3.11 >/dev/null 2>&1; then PYTHON=$$(command -v python3.11); \
		elif [ -x /opt/homebrew/opt/python@3.11/bin/python3.11 ]; then PYTHON=/opt/homebrew/opt/python@3.11/bin/python3.11; \
		elif [ -x /usr/local/opt/python@3.11/bin/python3.11 ]; then PYTHON=/usr/local/opt/python@3.11/bin/python3.11; fi; \
	fi; \
	command -v "$$PYTHON" >/dev/null 2>&1 || { echo "Python is required; run 'make packages' first." >&2; exit 1; }; \
	echo "Creating/updating Python environment with $$PYTHON at $(PYTHON_ENV)"; \
	"$$PYTHON" -m venv "$(PYTHON_ENV)"; \
	"$(PYTHON_ENV)/bin/python" -m pip install --upgrade pip; \
	"$(PYTHON_ENV)/bin/python" -m pip install -r requirements.txt; \
	"$(PYTHON_ENV)/bin/python" -c 'import pretty_errors' >/dev/null 2>&1 || true

cmake:
ifeq ($(OS),Darwin)
	brew install cmake
else
	sudo apt install -y cmake
endif

llvm:
ifeq ($(OS),Darwin)
	brew install llvm
else
	@echo "Install a selected LLVM release with: install_llvm <version>"
endif

opencv:
ifeq ($(OS),Darwin)
	brew install opencv
else
	@echo "Install a selected OpenCV release with: install_opencv <version>"
endif

microsoft:
ifeq ($(OS),Darwin)
	brew install --cask visual-studio-code microsoft-edge
else
	@echo "Installing Microsoft Edge and VS Code Insiders"
	sudo apt update
	sudo apt install -y apt-transport-https ca-certificates curl software-properties-common wget gpg
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg >/dev/null
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
	sudo apt update
	sudo apt install -y microsoft-edge-stable
	sudo snap install --classic code-insiders
endif

docker:
ifeq ($(OS),Darwin)
	brew install --cask docker
	@echo "Start Docker.app once to finish setup. NVIDIA/CUDA containers are not supported on Apple Silicon."
else
	@command -v apt >/dev/null 2>&1 || { echo "Linux Docker installation currently supports Debian/Ubuntu (apt) only." >&2; exit 1; }
	sudo apt update
	sudo apt install -y docker.io
	sudo systemctl --now enable docker
	sudo usermod -aG docker "$$(whoami)"
	@echo "Docker installed. Log out and back in to apply docker group membership."
	@echo "Install NVIDIA Container Toolkit separately when this host has an NVIDIA GPU."
endif

doctor:
	@echo "Platform: $(PLATFORM) ($(OS)), CPUs: $(CPU_COUNT)"
	@status=0; \
	for cmd in git stow zsh; do \
		if command -v "$$cmd" >/dev/null 2>&1; then \
			printf 'ok      %s -> %s\n' "$$cmd" "$$(command -v "$$cmd")"; \
		else \
			printf 'missing %s\n' "$$cmd"; status=1; \
		fi; \
	done; \
	exit $$status
	@PYTHON=python3; \
	if [ "$(OS)" = Darwin ]; then \
		if command -v python3.11 >/dev/null 2>&1; then PYTHON=$$(command -v python3.11); \
		elif [ -x /opt/homebrew/opt/python@3.11/bin/python3.11 ]; then PYTHON=/opt/homebrew/opt/python@3.11/bin/python3.11; \
		elif [ -x /usr/local/opt/python@3.11/bin/python3.11 ]; then PYTHON=/usr/local/opt/python@3.11/bin/python3.11; fi; \
	fi; \
	if command -v "$$PYTHON" >/dev/null 2>&1; then \
		printf 'ok      python -> %s\n' "$$PYTHON"; \
	else \
		printf 'missing python (expected %s)\n' "$$PYTHON"; \
		exit 1; \
	fi
ifeq ($(OS),Darwin)
	@if command -v brew >/dev/null 2>&1; then \
		printf 'ok      brew -> %s\n' "$$(command -v brew)"; \
		cellar=$$(brew --cellar 2>/dev/null || true); \
		if [ -n "$$cellar" ] && [ -w "$$cellar" ]; then echo 'ok      Homebrew Cellar is writable'; \
		else echo 'warning Homebrew Cellar is not writable'; fi; \
	else echo 'missing brew'; exit 1; fi
endif

validate:
	@zsh -n "$(DOTFILES_DIR)/.zshenv" "$(DOTFILES_DIR)/.config/zsh/.zshrc" \
		"$(DOTFILES_DIR)/.config/zsh/xdg.zsh" "$(DOTFILES_DIR)/.config/zsh/platform.zsh" \
		"$(DOTFILES_DIR)/.config/zsh/vanilla.zsh" "$(DOTFILES_DIR)/.config/zsh/zinit.zsh" \
		"$(DOTFILES_DIR)/.config/zsh/.fzf.zsh"
	@for script in "$(DOTFILES_DIR)"/.local/bin/*; do \
		case "$$(head -n 1 "$$script")" in \
			*python*) PYTHONPYCACHEPREFIX=/tmp/ubuntu-init-pycache python3 -m py_compile "$$script" ;; \
			*/*zsh*) zsh -n "$$script" ;; \
			*) bash -n "$$script" ;; \
		esac; \
	done
	@rm -rf /tmp/ubuntu-init-pycache
	@git diff --check
	@stow -n -R --target="$(HOME_DIR)" --no-folding $(STOW_PLATFORM_FLAGS) "$(DOTFILES_DIR)" >/dev/null 2>&1
	@echo "Validation completed for $(PLATFORM)"
