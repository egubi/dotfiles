# dotfiles

Personal dotfiles for macOS, Ubuntu/Debian Linux, and Windows WSL.

Manages: Zsh + Oh-My-Zsh, Starship prompt, shared aliases, and Git config.

## Quick start

```bash
git clone git@github.com:egubi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Then open a new terminal (or run `exec zsh`).

## What `install.sh` does

1. Detects your OS (macOS / Linux / WSL)
2. Installs [Starship](https://starship.rs) if not already present
3. Symlinks each config file to its expected location (see table below)
4. Backs up any existing files as `<file>.backup` before overwriting
5. Sets the platform-appropriate Git credential helper
6. Switches your default shell to zsh if needed

Safe to re-run — existing correct symlinks are left untouched.

## File locations after install

| Source | Symlinked to |
|---|---|
| `git/.gitconfig` | `~/.gitconfig` |
| `shell/.zshrc` | `~/.zshrc` |
| `shell/aliases.sh` | `~/.dotfiles/shell/aliases.sh` |
| `starship/starship.toml` | `~/.config/starship.toml` |

## First-time setup

Edit `git/.gitconfig` and set your name and email:

```ini
[user]
    name = Your Name
    email = your@email.com
```

## Prerequisites

| Tool | macOS | Linux / WSL |
|---|---|---|
| zsh | pre-installed | `sudo apt install zsh` (done by installer) |
| [Oh-My-Zsh](https://ohmyz.sh) | install manually | install manually |
| [Homebrew](https://brew.sh) | recommended | optional |
| curl | pre-installed | pre-installed |

Starship is installed automatically by the script.

## Aliases

| Alias | Command |
|---|---|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate --all` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `..` / `...` | go up 1 / 2 directories |
| `ll` | `ls -lhA` |
| `reload` | `source ~/.zshrc` |

## Adding a new machine

```bash
git clone <your-repo-url> ~/.dotfiles
~/.dotfiles/install.sh
```

That's it — the installer handles the rest.
