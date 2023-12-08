
# ==================================================================
# Install zinit if not exist
# ==================================================================
export ZINIT_PATH="$HOME/.zinit/bin"
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

zinit ice as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX"
zinit light tj/git-extras

# If completion is needed, de-comment lines below.
# this will add 200ms loading time.
# zinit ice wait lucid atload"zicompinit"
# zinit light zsh-users/zsh-completions

# https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
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
