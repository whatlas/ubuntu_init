
# ==================================================================
# Install zinit if it is not present.
# Set ZSH_AUTO_INSTALL_PLUGINS=0 to keep shell startup offline-only.
# ==================================================================
export ZINIT_PATH="$XDG_CONFIG_HOME/.zinit/bin"
typeset -g ZINIT_AVAILABLE=0
if [[ ! -r "$ZINIT_PATH/zinit.zsh" ]]; then
    if [[ "${ZSH_AUTO_INSTALL_PLUGINS:-1}" == 1 ]] && (( $+commands[git] )); then
        mkdir -p "${ZINIT_PATH:h}"
        git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_PATH" || return
    else
        print -u2 "zinit is missing; run with ZSH_AUTO_INSTALL_PLUGINS=1 or install it manually"
        return
    fi
fi

if [[ -r "$ZINIT_PATH/zinit.zsh" ]]; then
    source "$ZINIT_PATH/zinit.zsh"
    typeset -g ZINIT_AVAILABLE=1
fi

(( ZINIT_AVAILABLE )) || return 0

# ==================================================================
# claim plugins
# ==================================================================
zinit light jocelynmallon/zshmarks
zinit light mafredri/zsh-async
zinit light zsh-users/zsh-autosuggestions
zinit light z-shell/F-Sy-H
zinit light chrissicool/zsh-256color
# zinit light ptavares/zsh-exa
zinit light skywind3000/z.lua

zinit ice as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX"
zinit light tj/git-extras

if (( ! $+commands[bat] )); then
    zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
    zinit light sharkdp/bat
fi

if (( ! $+commands[fzf] )); then
    zinit ice from"gh-r" as"program"
    zinit light junegunn/fzf
fi

if (( ! $+commands[fd] )); then
    zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
    zinit light sharkdp/fd
fi

# If completion is needed, de-comment lines below.
# this will add 200ms loading time.
# zinit ice wait lucid atload"zicompinit"
# zinit light zsh-users/zsh-completions

# Rebuild the completion dump once per day; otherwise use the cached dump.
autoload -Uz compinit
zcompdump="$XDG_CACHE_HOME/zsh/.zcompdump-$ZSH_VERSION"
if [[ -s "$zcompdump" && -n "$zcompdump"(#qNm-1) ]]; then
    compinit -C -d "$zcompdump"
else
    compinit -d "$zcompdump"
fi
unset zcompdump

# update zinit, only run update or first install
# zinit self-update

# ZSH_AUTOSUGGEST
ZSH_AUTOSUGGEST_USE_ASYNC=1
# ZSH_HIGHLIGHT_STYLES[comment]=fg=245

# put these 2 lines at the end of plugins settings
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# --- }}}
