# A pure zsh config can be use in bare machine

# alias --- {{{

# dir
alias .='cd .'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
## Colorize the ls output ##
alias ls="ls --color=yes --group-directories-first -hFtr"

## Use a long listing format ##
alias ll='ls -lA'

## Show hidden files ##
alias l.='ls -d .* --color=auto'

## set some other defaults ##
alias df='df -H'

# Find the 10 most heavy files in a folder
alias hefi="du -hax --max-depth=1 *| sort -rh | head -13"

alias tree='tree -aC -I .git --dirsfirst'
alias rsync='rsync --verbose --archive --info=progress2 --human-readable --partial'
alias make='make -j`nproc`'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

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
# alias gd='git dif'
# alias ga='git add .'
# alias gc='git commit -m'
# alias g='gitui'
# alias glp='gl -p'
# alias glm='gl -m'
# alias glb='gl -b'
# alias glc='gl -c'

# script
alias python='python3'
alias pip='python3 -m pip'

# others
alias now='date +%s'
alias sz="source $HOME/.zshrc"

# VScode
alias code='code-insiders'

# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'

# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

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

for _enabled_path in $_enabled_paths[@]; do
    # only add to $PATH when path exist and path not in $PATH
    [[ -d "${_enabled_path}" ]] &&
        [[ ! :$PATH: == *":${_enabled_path}:"* ]] &&
        PATH="$PATH:${_enabled_path}"
done

# tab completion ignore case
# https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directories-and
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# History config
HISTSIZE=10000
SAVEHIST=10000

HISTFILE=$HOME/.zsh_history
setopt append_history
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
    if [[ "$#" != 0 ]]; then
        builtin cd "$@"
        return
    fi
    local dir="$(printf '%s\n' $(fd --type d --hidden --follow . "$HOME/code" | fzf))"
    [[ ${#dir} != 0 ]] || return 0
    builtin cd "$dir" &>/dev/null
}

rmf() {
    fd --hidden --follow | fzf | xargs rm -rf
}

mc() {
    mkdir -p -- "$1" && cd -P -- "$1"
}

hostip() {
    export HOST_IP="$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1)"
    echo $HOST_IP
}

ldpath() {
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$1
    echo "add $1 to LD_LIBRARY_PATH"
}

setpx() {
    export https_proxy=http://$1
    export http_proxy=http://$1
    export all_proxy=socks5://$1
    echo "set proxy to $1"
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
    export https_proxy=
    export http_proxy=
    export all_proxy=
    echo "set proxy to nil"
}

extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.tar.xz) tar xf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
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
