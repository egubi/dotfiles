# ── Shell options ────────────────────────────────────────────────────────────

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Auto-cd: type directory name to cd into it
setopt AUTO_CD

# ── Environment ──────────────────────────────────────────────────────────────

# Preferred editor
export EDITOR='vim'
export VISUAL='vim'

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# PATH additions
export PATH="$HOME/.local/bin:$PATH"

# ── Platform-specific setup ──────────────────────────────────────────────────

case "$(uname -s)" in
  Darwin)
    # Homebrew
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # zsh-autosuggestions (Homebrew)
    ZSH_AUTOSUGGEST_BREW="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$ZSH_AUTOSUGGEST_BREW" ]] && source "$ZSH_AUTOSUGGEST_BREW"
    
    # zsh-syntax-highlighting (Homebrew) — must be loaded after other ZLE widgets
    ZSH_HIGHLIGHT_BREW="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -f "$ZSH_HIGHLIGHT_BREW" ]] && source "$ZSH_HIGHLIGHT_BREW"
    ;;
    
  Linux)
    # Detect WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
      export IS_WSL=1
    fi
    
    # Linuxbrew / Homebrew on Linux
    [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # zsh-autosuggestions (apt)
    ZSH_AUTOSUGGEST_APT="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$ZSH_AUTOSUGGEST_APT" ]] && source "$ZSH_AUTOSUGGEST_APT"
    
    # zsh-syntax-highlighting (apt) — must be loaded after other ZLE widgets
    ZSH_HIGHLIGHT_APT="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -f "$ZSH_HIGHLIGHT_APT" ]] && source "$ZSH_HIGHLIGHT_APT"
    ;;
esac

# ── Plugins & Tools ──────────────────────────────────────────────────────────

# zoxide (modern replacement for z/autojump)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

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

# ── Aliases ──────────────────────────────────────────────────────────────────

# Source shared aliases
[[ -f "$HOME/.dotfiles/shell/aliases.sh" ]] && source "$HOME/.dotfiles/shell/aliases.sh"

# ── Prompt ───────────────────────────────────────────────────────────────────

# Starship prompt — must be last
eval "$(starship init zsh)"
