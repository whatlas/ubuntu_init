# Platform-specific environment and command compatibility.

case "$OSTYPE" in
    darwin*)
        if [[ -x /opt/homebrew/bin/brew ]]; then
            export HOMEBREW_PREFIX="/opt/homebrew"
            export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
            export HOMEBREW_REPOSITORY="/opt/homebrew"
            path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
            export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
            export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
        elif [[ -x /usr/local/bin/brew ]]; then
            export HOMEBREW_PREFIX="/usr/local"
            export HOMEBREW_CELLAR="/usr/local/Cellar"
            export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
            path=(/usr/local/bin /usr/local/sbin $path)
        fi

        export CLICOLOR=1
        alias ls='ls -GhFtr'
        hefi() {
            du -hd 1 . 2>/dev/null | sort -hr | head -20
        }

        _cpu_count() {
            sysctl -n hw.logicalcpu 2>/dev/null || echo 1
        }

        hostip() {
            local interface
            interface=$(route get default 2>/dev/null | awk '/interface:/{print $2; exit}')
            if [[ -n "$interface" ]]; then
                export HOST_IP="$(ipconfig getifaddr "$interface" 2>/dev/null)"
            else
                export HOST_IP=""
            fi
            echo "$HOST_IP"
        }
        ;;
    linux*)
        alias ls='ls --color=yes --group-directories-first -hFtr'
        hefi() {
            du -hax --max-depth=1 | sort -rh | head -20
        }
        alias chown='chown --preserve-root'
        alias chmod='chmod --preserve-root'
        alias chgrp='chgrp --preserve-root'

        _cpu_count() {
            nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1
        }

        hostip() {
            export HOST_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
            echo "$HOST_IP"
        }
        ;;
    *)
        _cpu_count() {
            echo 1
        }
        ;;
esac

export MAKEFLAGS="${MAKEFLAGS:--j$(_cpu_count)}"
unfunction _cpu_count

if [[ -d "$XDG_DATA_HOME/ubuntu-init/venv/bin" ]]; then
    path=("$XDG_DATA_HOME/ubuntu-init/venv/bin" $path)
fi
