# Enable Powerlevel10k instant prompt. Must stay at the very top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ────────────────────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zoxide
)

source "$ZSH/oh-my-zsh.sh"

# ── History ──────────────────────────────────────────────────────────────────

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY APPEND_HISTORY AUTO_CD BANG_HIST

# ── Environment ──────────────────────────────────────────────────────────────

export EDITOR='vim'
export VISUAL='vim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="$HOME/.local/bin:$PATH"

# ── Platform-specific setup ──────────────────────────────────────────────────

case "$(uname -s)" in
  Darwin)
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      export IS_WSL=1
    fi
    [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && \
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
esac

# ── Tools ────────────────────────────────────────────────────────────────────

# nvm — lazy-load to keep startup fast
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init - zsh)"
fi

# ── Aliases ──────────────────────────────────────────────────────────────────

[[ -f "$HOME/.dotfiles/shell/aliases.sh" ]] && source "$HOME/.dotfiles/shell/aliases.sh"

# ── Powerlevel10k config ──────────────────────────────────────────────────────

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"


# development
alias gg="git add * --ignore-errors&&git commit -m "go"&&git push"
alias dcb="docker-compose up --build"
# kubernetes
alias k=kubectl
alias kx=kubectx
export KUBECONFIG=$(find /Users/gubi/Dropbox/3-Resources/kubernetes/_configs/*.config.yaml -type f | tr '\n' ':')
# export PATH="$HOME/.local/bin:$PATH"
alias tp="terraform plan"
alias ta="terraform apply"
alias td="terraform destroy"
alias pip="curl https://checkip.amazonaws.com"