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

# Usage: link_file <source> <destination>
link_file() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  # Create parent directories if needed
  mkdir -p "$dst_dir"

  # Already the correct symlink — nothing to do
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    success "Already linked: $dst"
    return
  fi

  # Back up existing file/symlink
  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="${dst}.backup"
    warn "Backing up $dst → $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  success "Linked: $dst → $src"
}

# ── Starship installation ─────────────────────────────────────────────────────

install_starship() {
  if command -v starship &>/dev/null; then
    success "Starship already installed: $(starship --version)"
    return
  fi

  info "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  success "Starship installed."
}

# ── Git credential helper per platform ───────────────────────────────────────

configure_git_credential_helper() {
  local helper
  case "$OS" in
    macos) helper="osxkeychain" ;;
    wsl)   helper="manager" ;;
    linux) helper="store" ;;
  esac

  # Inject [credential] block only if not already present in the symlinked config
  local gitconfig="$HOME/.gitconfig"
  if ! git config --global --get credential.helper &>/dev/null; then
    git config --global credential.helper "$helper"
    info "Git credential helper set to: $helper"
  else
    info "Git credential helper already configured."
  fi
}

# ── main ──────────────────────────────────────────────────────────────────────

main() {
  install_starship

  # Symlink dotfiles
  link_file "$DOTFILES_DIR/git/.gitconfig"          "$HOME/.gitconfig"
  link_file "$DOTFILES_DIR/shell/.zshrc"            "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/shell/aliases.sh"        "$HOME/.dotfiles/shell/aliases.sh"
  link_file "$DOTFILES_DIR/starship/starship.toml"  "$HOME/.config/starship.toml"

  configure_git_credential_helper

  # Platform-specific package nudges
  case "$OS" in
    macos)
      if ! command -v brew &>/dev/null; then
        warn "Homebrew not found. Install it from https://brew.sh then re-run this script."
      fi
      ;;
    linux|wsl)
      if ! command -v zsh &>/dev/null; then
        info "Installing zsh..."
        sudo apt-get update -qq && sudo apt-get install -y zsh
      fi
      ;;
  esac

  # Set zsh as default shell if it isn't already
  if [[ "$SHELL" != *zsh ]]; then
    local zsh_path
    zsh_path="$(command -v zsh)"
    info "Changing default shell to $zsh_path (you may be prompted for your password)"
    chsh -s "$zsh_path"
  fi

  echo ""
  success "Done! Open a new terminal (or run: exec zsh) to load your new config."
}

main "$@"
