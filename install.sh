#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ──────────────────────────────────────────────────────────────────

info()    { printf "\033[0;34m[info]\033[0m  %s\n" "$*"; }
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$*"; }
warn()    { printf "\033[0;33m[warn]\033[0m  %s\n" "$*"; }
error()   { printf "\033[0;31m[error]\033[0m %s\n" "$*" >&2; }

# ── OS detection ─────────────────────────────────────────────────────────────

detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$(uname -s)" == "Linux" ]]; then
    echo "linux"
  else
    error "Unsupported OS: $(uname -s)"
    exit 1
  fi
}

OS="$(detect_os)"
info "Detected OS: $OS"

# ── backup + symlink ──────────────────────────────────────────────────────────

link_file() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  mkdir -p "$dst_dir"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    success "Already linked: $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="${dst}.backup"
    warn "Backing up $dst → $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  success "Linked: $dst → $src"
}

# ── Homebrew ──────────────────────────────────────────────────────────────────

require_brew() {
  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found. Install it from https://brew.sh then re-run this script."
    exit 1
  fi
}

brew_install() {
  local pkg="$1"
  if brew list "$pkg" &>/dev/null; then
    success "$pkg already installed"
  else
    info "Installing $pkg via Homebrew..."
    brew install "$pkg"
    success "$pkg installed"
  fi
}

brew_cask_install() {
  local pkg="$1"
  if brew list --cask "$pkg" &>/dev/null; then
    success "$pkg (cask) already installed"
  else
    info "Installing $pkg via Homebrew Cask..."
    brew install --cask "$pkg"
    success "$pkg installed"
  fi
}

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────

install_omz() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh already installed"
    return
  fi
  info "Installing Oh My Zsh..."
  # Install unattended (RUNZSH=no prevents it from launching a new shell)
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed"
}

# ── Powerlevel10k ─────────────────────────────────────────────────────────────

install_p10k() {
  local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ -d "$p10k_dir" ]]; then
    success "Powerlevel10k already installed"
    return
  fi
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  success "Powerlevel10k installed"
}

# ── OMZ custom plugins ────────────────────────────────────────────────────────

install_omz_plugin() {
  local name="$1"
  local repo="$2"
  local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
  if [[ -d "$plugin_dir" ]]; then
    success "OMZ plugin $name already installed"
    return
  fi
  info "Installing OMZ plugin: $name..."
  git clone --depth=1 "$repo" "$plugin_dir"
  success "OMZ plugin $name installed"
}

# ── macOS setup ──────────────────────────────────────────────────────────────

install_macos() {
  require_brew

  brew_install zsh
  brew_install zoxide

  # Nerd Font required by Powerlevel10k (MesloLGS NF)
  brew tap homebrew/cask-fonts 2>/dev/null || true
  brew_cask_install font-meslo-lg-nerd-font
}

# ── Linux setup ──────────────────────────────────────────────────────────────

install_linux() {
  local packages=(zsh curl git)
  for pkg in "${packages[@]}"; do
    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
      success "$pkg already installed"
    else
      info "Installing $pkg via apt..."
      sudo apt-get update -qq && sudo apt-get install -y "$pkg"
      success "$pkg installed"
    fi
  done

  # zoxide
  if ! command -v zoxide &>/dev/null; then
    info "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    success "zoxide installed"
  else
    success "zoxide already installed"
  fi

  # Fonts only make sense on a local machine — skip when running over SSH
  if [[ -n "${SSH_CLIENT:-}${SSH_TTY:-}" ]]; then
    warn "SSH session detected — skipping font install (fonts must be installed on your local machine)."
    return
  fi

  # MesloLGS Nerd Font
  local font_dir="$HOME/.local/share/fonts"
  if fc-list | grep -qi "MesloLGS"; then
    success "MesloLGS Nerd Font already installed"
  else
    info "Installing MesloLGS Nerd Font..."
    mkdir -p "$font_dir"
    local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    for font in \
      "MesloLGS NF Regular.ttf" \
      "MesloLGS NF Bold.ttf" \
      "MesloLGS NF Italic.ttf" \
      "MesloLGS NF Bold Italic.ttf"; do
      curl -fsSL "$base_url/${font// /%20}" -o "$font_dir/$font"
    done
    fc-cache -f "$font_dir"
    success "MesloLGS Nerd Font installed — set your terminal font to 'MesloLGS NF'"
  fi
}

# ── pyenv setup ──────────────────────────────────────────────────────────────

install_pyenv() {
  # Only install on Linux/WSL
  if [[ "$OS" != "linux" && "$OS" != "wsl" ]]; then
    return
  fi

  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"

  # Check if pyenv is already installed
  if [[ -d "$PYENV_ROOT" ]]; then
    success "pyenv already installed"
  else
    info "Installing build dependencies for Python compilation..."
    sudo apt-get update -qq
    sudo apt-get install -y \
      build-essential \
      libssl-dev \
      zlib1g-dev \
      libbz2-dev \
      libreadline-dev \
      libsqlite3-dev \
      curl \
      git \
      libncursesw5-dev \
      xz-utils \
      tk-dev \
      libxml2-dev \
      libxmlsec1-dev \
      libffi-dev \
      liblzma-dev
    success "Build dependencies installed"

    info "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    success "pyenv installed"
  fi

  # Initialize pyenv for the current shell session
  eval "$(pyenv init -)"

  # Install Python 3.12.2 if not already installed
  local python_version="3.12.2"
  if pyenv versions --bare | grep -q "^${python_version}$"; then
    success "Python $python_version already installed"
  else
    info "Installing Python $python_version (this may take several minutes)..."
    pyenv install "$python_version"
    success "Python $python_version installed"
  fi

  # Set as global default if not already set
  local current_global
  current_global="$(pyenv global 2>/dev/null || echo '')"
  if [[ "$current_global" == "$python_version" ]]; then
    success "Python $python_version already set as global default"
  else
    info "Setting Python $python_version as global default..."
    pyenv global "$python_version"
    success "Python $python_version set as global default"
  fi

  # Verify installation
  if command -v pyenv &>/dev/null; then
    success "pyenv verification: $(pyenv --version)"
    success "Python verification: $(pyenv which python) (version $(pyenv version-name))"
  fi
}

# ── Git credential helper ─────────────────────────────────────────────────────

configure_git_credential_helper() {
  local helper
  case "$OS" in
    macos) helper="osxkeychain" ;;
    wsl)   helper="manager" ;;
    linux) helper="store" ;;
  esac

  if ! git config --global --get credential.helper &>/dev/null; then
    git config --global credential.helper "$helper"
    info "Git credential helper set to: $helper"
  else
    info "Git credential helper already configured."
  fi
}

# ── main ──────────────────────────────────────────────────────────────────────

main() {
  case "$OS" in
    macos)         install_macos ;;
    linux|wsl)     install_linux ;;
  esac

  install_omz
  install_p10k
  install_omz_plugin zsh-autosuggestions \
    https://github.com/zsh-users/zsh-autosuggestions
  install_omz_plugin zsh-syntax-highlighting \
    https://github.com/zsh-users/zsh-syntax-highlighting

  # Install pyenv (Linux/WSL only)
  install_pyenv

  # Symlink dotfiles
  link_file "$DOTFILES_DIR/git/.gitconfig"        "$HOME/.gitconfig"
  link_file "$DOTFILES_DIR/shell/.zshrc"          "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/shell/aliases.sh"      "$HOME/.dotfiles/shell/aliases.sh"
  link_file "$DOTFILES_DIR/shell/.p10k.zsh"       "$HOME/.p10k.zsh"

  configure_git_credential_helper

  # Set zsh as default shell
  if [[ "$SHELL" != *zsh ]]; then
    local zsh_path
    zsh_path="$(command -v zsh)"
    info "Changing default shell to $zsh_path (you may be prompted for your password)"
    chsh -s "$zsh_path"
  fi

  echo ""
  success "Done! Open a new terminal to load your new config."
  warn "Remember to set your terminal font to 'MesloLGS NF' for Powerlevel10k glyphs."
}

main "$@"
