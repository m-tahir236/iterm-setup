#!/usr/bin/env bash
# =============================================================================
# dotfiles/setup.sh — Bootstrap script for Jack's terminal environment
# Usage: bash setup.sh
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$DOTFILES_DIR/home"

echo "==> Dotfiles directory: $DOTFILES_DIR"

# -----------------------------------------------------------------------------
# Helper: create a symlink, backing up any existing file first
# -----------------------------------------------------------------------------
link() {
  local src="$1"   # file inside dotfiles/home/
  local dest="$2"  # target location in $HOME

  if [ -L "$dest" ]; then
    echo "    [skip] $dest is already a symlink"
    return
  fi

  if [ -e "$dest" ]; then
    echo "    [backup] $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "    [link] $dest -> $src"
}

# -----------------------------------------------------------------------------
# 1. Install Oh My Zsh (skip if already installed)
# -----------------------------------------------------------------------------
echo ""
echo "==> Checking Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "    Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "    [skip] Oh My Zsh already installed"
fi

# -----------------------------------------------------------------------------
# 2. Install custom plugins and themes (clone if missing)
# -----------------------------------------------------------------------------
echo ""
echo "==> Installing Oh My Zsh plugins and themes..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
  local repo="$1"
  local dest="$2"
  if [ ! -d "$dest" ]; then
    echo "    Cloning $repo..."
    git clone --depth=1 "https://github.com/$repo.git" "$dest"
  else
    echo "    [skip] $(basename "$dest") already present"
  fi
}

clone_if_missing "romkatv/powerlevel10k"            "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing "zsh-users/zsh-autosuggestions"    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "zsh-users/zsh-completions"        "$ZSH_CUSTOM/plugins/zsh-completions"
clone_if_missing "zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# -----------------------------------------------------------------------------
# 3. Symlink dotfiles from home/ to $HOME
# -----------------------------------------------------------------------------
echo ""
echo "==> Creating symlinks..."

link "$HOME_DIR/.zshrc"              "$HOME/.zshrc"
link "$HOME_DIR/.p10k.zsh"           "$HOME/.p10k.zsh"
link "$HOME_DIR/.gitconfig"          "$HOME/.gitconfig"
link "$HOME_DIR/.vimrc"              "$HOME/.vimrc"
link "$HOME_DIR/.config/git/ignore"  "$HOME/.config/git/ignore"

# -----------------------------------------------------------------------------
# 4. iTerm2 preferences
# -----------------------------------------------------------------------------
echo ""
echo "==> iTerm2 preferences"
echo "    To load your iTerm2 settings on this machine:"
echo "    1. Open iTerm2"
echo "    2. Go to: Preferences → General → Preferences"
echo "    3. Check 'Load preferences from a custom folder or URL'"
echo "    4. Set the folder to: $DOTFILES_DIR/iterm2"
echo "    5. Click 'Restart' when prompted"
echo ""
echo "    (On the original machine, also enable 'Save changes to folder when iTerm2 quits')"

# -----------------------------------------------------------------------------
echo ""
echo "==> Done! Open a new terminal tab to see your shell setup."
