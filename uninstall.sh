#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ──────────────────────────────────────────────────────────────────

info()    { printf "\033[0;34m[info]\033[0m  %s\n" "$*"; }
success() { printf "\033[0;32m[ok]\033[0m    %s\n" "$*"; }
warn()    { printf "\033[0;33m[warn]\033[0m  %s\n" "$*"; }

confirm() {
  local prompt="$1"
  printf "\033[0;33m[?]\033[0m    %s [y/N] " "$prompt"
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ── symlink removal + backup restore ─────────────────────────────────────────

unlink_file() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    rm "$dst"
    success "Removed symlink: $dst"
  elif [[ -L "$dst" ]]; then
    warn "Skipping $dst — symlink exists but points elsewhere (not ours)"
    return
  else
    warn "Skipping $dst — not a symlink"
    return
  fi

  # Restore backup if one exists
  local backup="${dst}.backup"
  if [[ -e "$backup" ]]; then
    mv "$backup" "$dst"
    success "Restored backup: $backup → $dst"
  fi
}

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────

remove_omz() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Oh My Zsh not found — nothing to remove"
    return
  fi
  if confirm "Remove Oh My Zsh (and Powerlevel10k + plugins inside it)?"; then
    rm -rf "$HOME/.oh-my-zsh"
    success "Oh My Zsh removed"
  else
    info "Skipped Oh My Zsh removal"
  fi
}

# ── Git credential helper ─────────────────────────────────────────────────────

remove_git_credential_helper() {
  if git config --global --get credential.helper &>/dev/null; then
    if confirm "Remove global Git credential helper setting?"; then
      git config --global --unset credential.helper
      success "Git credential helper removed"
    else
      info "Skipped Git credential helper removal"
    fi
  else
    info "No Git credential helper set — nothing to remove"
  fi
}

# ── Default shell ─────────────────────────────────────────────────────────────

revert_shell() {
  if [[ "$SHELL" != *zsh ]]; then
    info "Default shell is not zsh — nothing to revert"
    return
  fi
  if confirm "Revert default shell from zsh back to bash?"; then
    local bash_path
    bash_path="$(command -v bash)"
    chsh -s "$bash_path"
    success "Default shell reverted to $bash_path"
  else
    info "Skipped shell revert"
  fi
}

# ── main ──────────────────────────────────────────────────────────────────────

main() {
  echo ""
  warn "This will undo the changes made by install.sh."
  warn "Packages (zsh, zoxide) and fonts are NOT removed."
  echo ""

  if ! confirm "Continue with uninstall?"; then
    info "Aborted."
    exit 0
  fi

  echo ""

  # Remove symlinks and restore backups
  unlink_file "$DOTFILES_DIR/git/.gitconfig"        "$HOME/.gitconfig"
  unlink_file "$DOTFILES_DIR/shell/.zshrc"          "$HOME/.zshrc"
  unlink_file "$DOTFILES_DIR/shell/.p10k.zsh"       "$HOME/.p10k.zsh"
  unlink_file "$DOTFILES_DIR/shell/aliases.sh"      "$HOME/.dotfiles/shell/aliases.sh"

  remove_omz
  remove_git_credential_helper
  revert_shell

  echo ""
  success "Uninstall complete. Open a new terminal to apply changes."
}

main "$@"
