if [ -n "${ZSH_DEBUGRC+1}" ]; then
	zmodload zsh/zprof
fi

export XDG_CONFIG_HOME="$HOME/.config"
export ZSH_CONF="$XDG_CONFIG_HOME/zsh"

# import from secret project
_config_files=(
	"/etc/profile.d/cntlm.sh"
	"$ZSH_CONF/xdg.zsh"
	"$ZSH_CONF/platform.zsh"
	"$ZSH_CONF/vanilla.zsh"
	"$ZSH_CONF/lscolors.zsh"
	"$ZSH_CONF/zinit.zsh"
)

for _config_file in "${_config_files[@]}"; do
	[[ -f "$_config_file" ]] && source "$_config_file"
done
unset _config_file _config_files

# starship --- {{{
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/config.toml"
if (( $+commands[starship] )); then
	eval "$(starship init zsh)"
elif (( ${ZINIT_AVAILABLE:-0} )); then
	zinit ice from"gh-r" as"command" atload'eval "$(starship init zsh)"'
	zinit load starship/starship
fi
# --- }}}

# must be end --- {{{

# # fzf
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border'
export FZF_COMPLETION_TRIGGER='ll'
if (( $+commands[fd] )); then
	export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
_fzf_compgen_dir() {
	local search_root="$HOME/code"
	[[ -d "$search_root" ]] || search_root="$HOME"
	if (( $+commands[fd] )); then
		fd --type d --hidden --follow --exclude .git . "$search_root"
	else
		find "$search_root" -type d -not -path '*/.git/*' 2>/dev/null
	fi
}
if (( $+commands[fzf] )) && [[ -f "$ZSH_CONF/.fzf.zsh" ]]; then
	source "$ZSH_CONF/.fzf.zsh"
fi

# --- }}
if [ -n "${ZSH_DEBUGRC+1}" ]; then
	zprof
fi

export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
