# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gbr='git branch'
alias gst='git stash'
alias gstp='git stash pop'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Listing
alias ll='ls -lhA'
alias la='ls -A'
alias l='ls -CF'

# Safety nets
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Misc
alias reload='source ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn'
alias myip='curl -s https://ifconfig.me'
