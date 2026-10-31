# NIGHTHAWK OS - interactive shell environment (profile.d)
# Installed as /etc/profile.d/nighthawk.sh on the NIGHTHAWK image.

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=nano
export VISUAL=nano
export HISTSIZE=2000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export TERM=xterm-256color

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin:$HOME/.cargo/bin"

export PS1='\u@\h:\w\$ '

alias ll='ls -lh --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias sysinfo='cat /etc/nighthawk-release 2>/dev/null; uname -a; free -h; df -h'

mkcd() { mkdir -p "$1" && cd "$1"; }

# NIGHTHAWK welcome banner on login shells
if [ -r /etc/motd ]; then
  cat /etc/motd
fi
