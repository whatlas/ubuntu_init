if [ -n "${ZSH_DEBUGRC+1}" ]; then
	zmodload zsh/zprof
fi

export ZSH_CONF="$HOME/.config/zsh"

# import from secret project
_config_files=(
	"$ZSH_CONF/xdg.zsh"
	"$ZSH_CONF/vanilla.zsh"
	"$ZSH_CONF/lscolors.zsh"
	"$ZSH_CONF/zinit.zsh"
)

for _config_file in $_config_files[@]; do
	[[ -f "${_config_file}" ]] && source "${_config_file}"
done

# starship --- {{{
export STARSHIP_CONFIG=$HOME/.config/zsh/config.toml
zinit ice from"gh-r" as"command" atload'eval "$(starship init zsh)"'
zinit load starship/starship
# --- }}}

# must be end --- {{{

# # fzf
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border'
export FZF_COMPLETION_TRIGGER='ll'
_fzf_compgen_dir() {
	fd --type d --hidden --follow . "$HOME/code"
}
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# --- }}
if [ -n "${ZSH_DEBUGRC+1}" ]; then
	zprof
fi
