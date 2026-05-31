# dotfiles

Personal dotfiles for macOS, Ubuntu/Debian Linux, and Windows WSL.

Manages: Zsh + Oh My Zsh + Powerlevel10k prompt, shared aliases, and Git config.

## Quick start

```bash
git clone git@github.com:egubi/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Then open a new terminal (or run `exec zsh`).

## Uninstall

```bash
./uninstall.sh
```

Removes symlinks (restoring any `.backup` files), Oh My Zsh, Powerlevel10k, and optionally reverts the Git credential helper and default shell. Packages (zsh, zoxide) and fonts are left in place.

## What `install.sh` does

1. Detects your OS (macOS / Linux / WSL)
2. Installs packages: `zsh`, `zoxide`, MesloLGS Nerd Font
3. Installs [Oh My Zsh](https://ohmyz.sh)
4. Installs [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
5. Installs `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
6. **Linux/WSL only**: Installs [pyenv](https://github.com/pyenv/pyenv) + Python 3.12.2
7. Symlinks each config file to its expected location (see table below)
8. Backs up any existing files as `<file>.backup` before overwriting
9. Sets the platform-appropriate Git credential helper
10. Switches your default shell to zsh if needed

Safe to re-run — existing correct symlinks are left untouched.

## File locations after install

| Source | Symlinked to |
|---|---|
| `git/.gitconfig` | `~/.gitconfig` |
| `shell/.zshrc` | `~/.zshrc` |
| `shell/.p10k.zsh` | `~/.p10k.zsh` |
| `shell/aliases.sh` | `~/.dotfiles/shell/aliases.sh` |

## Terminal font setup (required for Powerlevel10k)

Powerlevel10k uses special glyphs that require **MesloLGS NF** to be set as your terminal's font. The installer installs the font files automatically on local machines.

> **Remote/SSH machines**: the font must be installed on your *local* machine (the one running the terminal emulator), not the server. The installer skips font installation automatically when it detects an SSH session.

Set the font in your terminal:

**iTerm2**
> Settings → Profiles → Text → Font → `MesloLGS NF`

**Terminal.app**
> Settings → Profiles → (select profile) → Font → `MesloLGS NF`

**VS Code integrated terminal** — add to `settings.json`:
```json
"terminal.integrated.fontFamily": "MesloLGS NF"
```

**Warp**
> Settings → Appearance → Text → Terminal Font → `MesloLGS NF`

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
| [Homebrew](https://brew.sh) | required | optional |
| `curl` / `git` | pre-installed | pre-installed |

Everything else (zsh, OMZ, P10k, plugins, font) is installed automatically.

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

## Python version management (Linux/WSL)

On Linux and WSL, the installer automatically sets up [pyenv](https://github.com/pyenv/pyenv) for managing Python versions.

**What's installed**:
- pyenv (with all build dependencies for compiling Python)
- Python 3.12.2 (set as global default)
- Configured in `.zshrc` with proper initialization

**Common pyenv commands**:

```bash
# List installed Python versions
pyenv versions

# List all available Python versions
pyenv install --list

# Install a specific version
pyenv install 3.11.7

# Set global default
pyenv global 3.12.2

# Set local version for current directory (creates .python-version file)
pyenv local 3.11.7

# Show current active version
pyenv version
```

**Using with direnv**:

Create a `.envrc` file in your project directory:

```bash
# Use pyenv Python version
layout pyenv 3.12.2
```

Then activate it:

```bash
direnv allow
```

The combination of pyenv + direnv allows automatic Python version switching per directory.
