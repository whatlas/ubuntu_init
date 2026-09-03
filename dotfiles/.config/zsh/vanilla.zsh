# A pure zsh config can be use in bare machine

# alias --- {{{

# dir
alias .='cd .'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
## Colorized ls and platform-specific flags are defined in platform.zsh.

# ## Use a long listing format ##
alias ll='ls -lA'

# ## Show hidden files ##
# alias l.='ls -d .* --color=auto'

## set some other defaults ##
alias df='df -H'

# Disk-usage compatibility alias is defined in platform.zsh.

(( $+commands[tree] )) && alias tree='tree -aC -I .git --dirsfirst'
alias rsync='rsync --verbose --archive --human-readable --partial'

## Colorize grep output when supported.
if print -r -- x | command grep --color=auto -q x 2>/dev/null; then
    alias grep='grep --color=auto'
    alias egrep='grep -E --color=auto'
    alias fgrep='grep -F --color=auto'
else
    alias egrep='grep -E'
    alias fgrep='grep -F'
fi

# docker
# alias d='docker'
# alias dc='docker compose'
# alias dr='docker run --rm'
# alias dcup='docker compose up'
# alias dil='docker image ls'
# alias dcl='docker container ls -a'
# alias drm='docker rm'
# alias drmi='docker rmi'
# da() {
#     docker exec -it $1 /bin/bash
# }

# git
alias gst='git status'
alias gsm='git submodule'
# alias gd='git dif'
# alias ga='git add .'
# alias gc='git commit -m'
# alias g='gitui'
# alias glp='gl -p'
# alias glm='gl -m'
# alias glb='gl -b'
# alias glc='gl -c'

# Python
alias python='python3'
alias pip='python3 -m pip'

# others
alias now='date +%s'
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"

# VS Code
if (( $+commands[code-insiders] )); then
    alias codei='code-insiders'
elif (( $+commands[code] )); then
    alias codei='code'
fi

# do not delete / or prompt if deleting more than 3 files at a time #

# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# GNU preserve-root aliases are enabled on Linux in platform.zsh.

# config --- {{{

# path
_enabled_paths=(
    "$HOME/.local/bin" # my own tools

    "/usr/bin"
    "/usr/sbin"
    "/usr/local" # for go on macOS
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/local/cuda/bin" # CUDA: Ubuntu/Debian
    "/opt/cuda/bin"       # CUDA: Arch
)

for _enabled_path in "${_enabled_paths[@]}"; do
    # Only add an existing path that is not already present.
    [[ -d "$_enabled_path" ]] && path+=("$_enabled_path")
done
typeset -U path
unset _enabled_path _enabled_paths

# tab completion ignore case
# https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directories-and
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# History config
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt magicequalsubst
setopt autocd
setopt share_history
setopt long_list_jobs
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_no_store
setopt interactivecomments
zstyle ':completion:*' rehash true
# }}}

# function --- {{{

cd() {
    if (( $# != 0 )); then
        builtin cd "$@"
        return
    fi

    if (( ! $+commands[fd] || ! $+commands[fzf] )); then
        builtin cd "$HOME"
        return
    fi

    local search_root="$HOME/code"
    [[ -d "$search_root" ]] || search_root="$HOME"
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git . "$search_root" | fzf --select-1 --exit-0)
    [[ -n "$dir" ]] && builtin cd -- "$dir"
}

rmf() {
    if (( ! $+commands[fd] || ! $+commands[fzf] )); then
        print -u2 "rmf requires fd and fzf"
        return 1
    fi

    local selection
    selection=$(fd --hidden --follow --exclude .git | fzf --multi) || return 0
    [[ -n "$selection" ]] || return 0

    local -a selected
    selected=("${(@f)selection}")

    print -r -- "The following paths will be removed:"
    printf '  %s\n' "${selected[@]}"
    read -q "REPLY?Continue? [y/N] " || { echo; return 0; }
    echo
    rm -rf -- "${selected[@]}"
}

mc() {
    if (( $# != 1 )); then
        print -u2 "Usage: mc <directory>"
        return 2
    fi
    mkdir -p -- "$1" && builtin cd -P -- "$1"
}

# hostip is implemented per platform in platform.zsh.

ldpath() {
    if (( $# != 1 )); then
        print -u2 "Usage: ldpath <directory>"
        return 2
    fi
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$1"
    echo "Added $1 to LD_LIBRARY_PATH"
}

setpx() {
    if (( $# != 1 )); then
        print -u2 "Usage: setpx <host:port>"
        return 2
    fi
    export https_proxy="http://$1"
    export http_proxy="http://$1"
    export all_proxy="socks5://$1"
    echo "Set proxy to $1"
}

# px1() {
#     setpx 127.0.0.1:1080
# }

# px3() {
#     setpx 10.10.43.3:1080
# }

# px6() {
#     setpx 10.10.43.6:1080
# }

# px127() {
#     setpx 127.0.0.1:1080
# }

nopx() {
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
    echo "Proxy variables cleared"
}

last100_line_of_log() {
    if (( $# != 1 )); then
        print -u2 "Usage: last100_line_of_log <log_file_url>"
        return 2
    fi
    if (( ! $+commands[curl] )); then
        print -u2 "last100_line_of_log requires curl"
        return 1
    fi

    local log_file="$1"
    local accept_ranges
    accept_ranges=$(command curl --fail --silent --show-error --head "$log_file" |
        command grep -i '^Accept-Ranges:[[:space:]]*bytes' || true)

    if [[ -n "$accept_ranges" ]]; then
        echo "Fetching the final 64 KiB and showing its last 100 lines..."
        command curl --fail --silent --show-error --range -65536 "$log_file" | tail -n 100
    else
        echo "WARNING: The server did not advertise byte-range support." >&2
        echo "Fetching the complete response." >&2
        command curl --fail --silent --show-error "$log_file" | tail -n 100
    fi
}


extract() {
    if (( $# != 1 )); then
        print -u2 "Usage: extract <archive>"
        return 2
    fi
    if [[ ! -f "$1" ]]; then
        print -u2 "'$1' is not a valid file"
        return 1
    fi

    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz) tar xzf "$1" ;;
        *.tar.xz|*.tar) tar xf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar e "$1" ;;
        *.gz) gunzip "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) print -u2 "'$1' cannot be extracted via extract()"; return 1 ;;
    esac
}

show_user_usage() {
    echo "%MEM user"
    echo "=========="
    ps -axo user=,%mem= |
        awk '{usage[$1] += $2} END {for (user in usage) printf "%.1f %s\n", usage[user], user}' |
        sort -rn |
        head
}

# --- }}}

# keymap --- {{{

bindkey -e

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\ei' edit-command-line
bindkey '^n' autosuggest-accept # auto suggestion

# move cursor
# bindkey '\eH' backward-char
# bindkey '\eL' forward-char
# bindkey '\eJ' down-line-or-history
# bindkey '\eK' up-line-or-history
# bindkey '\eh' backward-word
# bindkey '\el' forward-word
# bindkey '\ej' beginning-of-line
# bindkey '\ek' end-of-line

# C-A: beginning-of-line
# C-E: end-of-line
# C-B: backward-char
# C-F: forward-char
# A-B: backward-word
# A-F: forward-word
# C-W: delete word before
# A-D: delete word after
# A-D: delete word after
# C-D: delete char after
# C-U: clear the entire line
# C-K: Clear the characters on the line after the current cursor position

# shortcuts
bindkey -s '\ee' 'vi . \n'
bindkey -s '\eo' 'cd ..\n'
bindkey -s '\e;' 'll\n'

# --- }}}
