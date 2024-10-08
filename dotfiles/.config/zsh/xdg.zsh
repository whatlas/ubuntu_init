mkdir_if_not_exist() {
    if [[ -d "$1" ]]; then
        return
    fi
    mkdir -p "$1"
}

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

mkdir_if_not_exist "$XDG_CONFIG_HOME"
mkdir_if_not_exist "$XDG_DATA_HOME"
mkdir_if_not_exist "$XDG_CACHE_HOME"
mkdir_if_not_exist "$XDG_CACHE_HOME/zsh"
mkdir_if_not_exist "$XDG_STATE_HOME"
mkdir_if_not_exist "$XDG_STATE_HOME/zsh"

export HISTFILE="$XDG_STATE_HOME"/zsh/history
export CONAN_USER_HOME="$XDG_CONFIG_HOME"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority
export _ZL_DATA="$XDG_DATA_HOME/zlua"

compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
