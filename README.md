# Development workstation bootstrap

这个仓库使用 GNU Stow 管理 dotfiles，并为 macOS 与 Ubuntu 提供各自的开发环境安装入口。

此外，仓库包含一个模块化的二选一排名工具，详见 [`ranker/README.md`](ranker/README.md)：

```bash
python3 -m ranker candidates.txt
```

## 快速开始

先查看将执行的命令和环境检查：

```bash
make help
make doctor
make validate
make -n bootstrap
```

确认无误后执行：

```bash
make bootstrap
```

`make bootstrap` 会安装平台软件包、部署 dotfiles/字体，并安装 Python 工具。它会修改用户环境，因此建议先执行上面的 dry-run。

## macOS（Apple Silicon / Intel）

### 前置条件

1. 安装 Xcode Command Line Tools：

   ```bash
   xcode-select --install
   ```

2. 安装 Homebrew：<https://brew.sh>

3. 执行：

   ```bash
   make packages
   make dotfiles
   make python
   ```

`make packages` 使用 `Brewfile` 安装基础命令行工具（包括 CMake、Ninja、fzf、fd、bat、Starship 和 Python 3.11）。Apple Silicon Homebrew 的 `/opt/homebrew` 会由 Zsh 配置自动加入环境；Intel Mac 同时兼容 `/usr/local`。若 `make doctor` 报告 Homebrew Cellar 不可写，应先按照 `brew doctor` 的建议修复 Homebrew 安装目录；不要用 `sudo brew`。LLVM、OpenCV、VS Code、Edge 和 Docker 保持为按需安装，避免基础 bootstrap 过重。

macOS 字体会从 `dotfiles/.local/share/fonts` 复制到 `~/Library/Fonts`。Linux 则继续使用 XDG 字体目录和 `fc-cache`。

### 可单独安装的工具

```bash
make cmake
make llvm
make opencv
make microsoft
make docker
```

- CMake、LLVM、OpenCV 通过 Homebrew 安装。
- Docker 使用 Docker Desktop。安装后需要手动启动一次 Docker.app。
- Apple Silicon 不支持 CUDA、cuDNN、TensorRT、nvidia-docker 或 `nvidia-smi`。
- PyTorch 项目应使用 MPS；CUDA/TensorRT 工作负载仍需远程 Ubuntu/NVIDIA 主机。

### Python

`requirements.txt` 中的 `nvitop` 只会在 Linux 安装。由于当前仍固定使用 Conan 1.58，Brewfile 暂时选择 Python 3.11；后续迁移 Conan 2 后可升级 Python 基线。

`make python` 会创建/更新专用环境 `~/.local/share/ubuntu-init/venv`，不会修改系统或 Homebrew Python。Zsh 启动时会在该环境存在的情况下把它的 `bin` 目录加入 PATH。

## Ubuntu

基础环境：

```bash
make packages
make dotfiles
make python
```

也可使用旧入口：

```bash
make sys_pack
```

### NVIDIA 驱动

以下步骤只适用于 Ubuntu/NVIDIA 主机：

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

CUDA、cuDNN、TensorRT 和 NVIDIA Container Toolkit 版本应根据 Ubuntu、驱动和目标框架的兼容矩阵单独选择，不再由通用 Docker target 自动安装。

### 源码工具脚本

Ubuntu 上仍可使用：

```bash
install_opencv <version>
install_llvm <version>
```

这些脚本依赖 Linux/apt，不应在 macOS 执行。macOS 请使用对应的 Make target/Homebrew。

## 常用 target

| 命令 | 用途 |
| --- | --- |
| `make doctor` | 检查平台、必要命令和 Homebrew 写权限 |
| `make validate` | 无副作用检查 Zsh、脚本、Git diff 和 Stow 冲突 |
| `make packages` | Homebrew 或 apt 安装系统工具 |
| `make dotfiles` | Stow 部署配置并安装字体 |
| `make fonts` | 单独安装/刷新字体 |
| `make python` | 安装当前平台 Python 依赖 |
| `make cmake` | 安装 CMake |
| `make llvm` | 安装 LLVM |
| `make opencv` | 安装 OpenCV |
| `make microsoft` | 安装 VS Code 与 Edge |
| `make docker` | 安装平台 Docker runtime |

## Zsh 平台兼容

命令行二进制（fzf、fd、bat、starship）优先使用 Homebrew；Zinit 仅在找不到对应命令时回退下载安装。设置 `ZSH_AUTO_INSTALL_PLUGINS=0` 可禁止首次 Shell 启动自动克隆 Zinit。

当前仓库根目录可能仍存在历史遗留的 `fonts/` 副本；它与 `dotfiles/.local/share/fonts/` 重复，现已通过 `.gitignore` 排除。确认不再需要后可以手动删除。

`dotfiles/.config/zsh/platform.zsh` 负责平台差异，包括：

- Homebrew shell environment
- GNU/BSD `ls`、`du` 参数差异
- Linux `--preserve-root` 别名
- CPU 并行数与 `MAKEFLAGS`
- macOS/Linux 主机 IP 获取

通用别名与函数继续放在 `vanilla.zsh`。
