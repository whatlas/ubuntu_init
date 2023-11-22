
export ZINIT_PATH="$HOME/.zinit/bin"



# ==================================================================
# Install zinit if not exist
# ==================================================================
if [ ! -f "$ZINIT_PATH/zinit.zsh" ]; then
	echo "Installing zinit ..."
	[ ! -d "$ZINIT_PATH" ] && mkdir -p "$ZINIT" 2> /dev/null
	if [ -x "$(which git)" ]; then
		# setpx
		git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_PATH
	else
		echo "ERROR: please install git before installation !!"
		exit 1
	fi
	if [ ! $? -eq 0 ]; then
		echo ""
		echo "ERROR: downloading zinit failed !!"
		exit 1
	fi;
	# zplug install
fi

# ==================================================================
# source zplug
# ==================================================================
source "$ZINIT_PATH/zinit.zsh"


# ==================================================================
# claim plugins
# ==================================================================
zinit light jocelynmallon/zshmarks
zinit light mafredri/zsh-async
# zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
# zinit light zsh-users/zsh-syntax-highlighting
zinit light z-shell/F-Sy-H

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
