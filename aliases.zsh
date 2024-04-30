# XAMPP aliases
alias xstart="sudo /opt/lampp/xampp start"
alias xstop="sudo /opt/lampp/xampp stop"
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
alias cat="bat"

# Productivity aliases
alias t="tmux"
alias ta="tmux a"
alias tls="tmux ls"
alias tk="tmux kill-session -t"
alias tks="tmux kill-server"
alias n="nvim"
alias nc="nvim ~/.config/nvim/init.lua"

alias hx="helix"
