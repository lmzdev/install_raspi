# This file is sourced by .bashrc

alias ccat='highlight -O ansi --force'
alias ip='ip -c'

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

alias g='git'
alias ga='git add'
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gco='git checkout'
alias glog='git log --oneline --decorate --graph'

alias py='python3'
alias clock='tty-clock -f "%d.%m.%Y" -S -c'
#alias btop='python3 ~/bpytop/bpytop.py'

alias t='ctemp=$(vcgencmd measure_temp)&&echo ${ctemp:5}'
