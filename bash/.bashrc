# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='exa --icons --group-directories-first'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias bye='shutdown -P now'

eval "$(zoxide init bash)"
eval "$(starship init bash)"
