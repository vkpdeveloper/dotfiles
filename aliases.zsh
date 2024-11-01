# XAMPP aliases
alias xstart="sudo /opt/lampp/xampp start"
alias xstop="sudo /opt/lampp/xampp stop"
alias startapache="sudo /opt/lampp/xampp startapache"
alias startmysql="sudo /opt/lampp/xampp startmysql"
alias xrestart="sudo /opt/lampp/xampp restart"

# Git aliases
alias gs="git status" 
alias gl="git log"
alias gp="git push"
alias gpl="git pull"
alias gplr="git pull --rebase"
alias gaa="git add ."

# hostname alias
alias myip="hostname -i"

# config files
alias i3c="nvim ~/.config/i3/config"
alias aka="nvim ~/aliases.zsh"

# pacman aka
alias syu="sudo pacman -Syu"
alias rcns="sudo pacman -Rcns"
alias runs="sudo pacman -Runs"

# Just some fun stuff
alias weather="curl -s wttr.in/bangalore | head -n -3"

# Productivity aliases
alias t="tmux"
alias tn="tmux new-session -s $(basename $(eval pwd))"
alias ta="tmux a"
alias tt="tmux a -t"
alias tls="tmux ls"
alias tk="tmux kill-session -t"
alias tks="tmux kill-server"
alias n="nvim ."

alias hx="helix"
alias open="xdg-open"

alias itday="ssh itday"

alias gh="history|grep"

alias vi="nvim"
alias vim="nvim"
alias v="nvim"

alias cls="clipy ls"

alias nvf="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

alias nodekillport="lsof -ti :3000"

alias la="eza --icons --long"

alias erp="cd /opt/lampp/htdocs/erp/application"

alias offlaptop="xrandr --output eDP-1-1 --off"
alias onlaptop="xrandr --output eDP-1-1 --mode 1920x1080"
alias onmonitor="xrandr --output HDMI-0 --mode 1920x1080"
