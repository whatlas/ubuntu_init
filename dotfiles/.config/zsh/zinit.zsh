
# ==================================================================
# Install zinit if not exist
# ==================================================================
export ZINIT_PATH="$XDG_CONFIG_HOME/.zinit/bin"
[ ! -d $ZINIT_PATH ] && mkdir -p "$(dirname $ZINIT_PATH)"
[ ! -d $ZINIT_PATH/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_PATH"

# ==================================================================
# source zplug
# ==================================================================
source "$ZINIT_PATH/zinit.zsh"


# ==================================================================
# claim plugins
# ==================================================================
zinit light jocelynmallon/zshmarks
zinit light mafredri/zsh-async
zinit light zsh-users/zsh-autosuggestions
zinit light z-shell/F-Sy-H
zinit light chrissicool/zsh-256color
zinit light ptavares/zsh-exa
zinit light skywind3000/z.lua

zinit ice as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX"
zinit light tj/git-extras

zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# If completion is needed, de-comment lines below.
# this will add 200ms loading time.
# zinit ice wait lucid atload"zicompinit"
# zinit light zsh-users/zsh-completions

# https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
autoload -Uz compinit
# if [ "$(find "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION" -mtime 1)" ] ; then
#   compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
# fi
# zinit cdreplay
for dump in "$XDG_CACHE_HOME"/zsh/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# update zinit, only run update or first install
# zinit self-update

# ZSH_AUTOSUGGEST
ZSH_AUTOSUGGEST_USE_ASYNC=1
# ZSH_HIGHLIGHT_STYLES[comment]=fg=245

# put these 2 lines at the end of plugins settings
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# --- }}}
