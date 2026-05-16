# Oh-My-Zsh setup
export ZSH="$HOME/.oh-my-zsh"

# Disable OMZ theme — Starship handles the prompt
ZSH_THEME=""

# OMZ plugins
plugins=(
  git
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  npm
)

source "$ZSH/oh-my-zsh.sh"

# Source shared aliases
[[ -f "$HOME/.dotfiles/shell/aliases.sh" ]] && source "$HOME/.dotfiles/shell/aliases.sh"

# Preferred editor
export EDITOR='vim'
export VISUAL='vim'

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# PATH additions — add your own below
export PATH="$HOME/.local/bin:$PATH"

# Node version manager (nvm) — lazy-load for fast startup
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# pyenv
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Platform-specific extras
case "$(uname -s)" in
  Darwin)
    # Homebrew
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;
  Linux)
    # Linuxbrew / Homebrew on Linux
    [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
esac

# Starship prompt — must be last
eval "$(starship init zsh)"
