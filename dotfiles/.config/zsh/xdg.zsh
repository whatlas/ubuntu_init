# XDG base directories and application state.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

mkdir -p \
    "$XDG_CONFIG_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_CACHE_HOME/zsh" \
    "$XDG_STATE_HOME/zsh"

export HISTFILE="$XDG_STATE_HOME/zsh/history"
export CONAN_USER_HOME="$XDG_CONFIG_HOME"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export _ZL_DATA="$XDG_DATA_HOME/zlua"

if (( $+commands[wget] )); then
    alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"
fi
