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

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "    [skip] $dest already linked"
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
# 1. Install fonts (MesloLGS NF — required by Powerlevel10k)
# -----------------------------------------------------------------------------
echo ""
echo "==> Installing MesloLGS NF fonts..."

FONTS_DEST="$HOME/Library/Fonts"
mkdir -p "$FONTS_DEST"
for font in "$DOTFILES_DIR/fonts"/*.ttf; do
  name="$(basename "$font")"
  if [ -f "$FONTS_DEST/$name" ]; then
    echo "    [skip] $name already installed"
  else
    cp "$font" "$FONTS_DEST/$name"
    echo "    [installed] $name"
  fi
done

# -----------------------------------------------------------------------------
# 2. Install Oh My Zsh (skip if already installed)
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
# 3. Install custom plugins and themes (clone if missing)
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

clone_if_missing "romkatv/powerlevel10k"             "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing "zsh-users/zsh-autosuggestions"     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "zsh-users/zsh-completions"         "$ZSH_CUSTOM/plugins/zsh-completions"
clone_if_missing "zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# -----------------------------------------------------------------------------
# 4. Symlink dotfiles from home/ to $HOME
# -----------------------------------------------------------------------------
echo ""
echo "==> Creating symlinks..."

link "$HOME_DIR/.zshrc"             "$HOME/.zshrc"
link "$HOME_DIR/.p10k.zsh"          "$HOME/.p10k.zsh"
link "$HOME_DIR/.gitconfig"         "$HOME/.gitconfig"
link "$HOME_DIR/.vimrc"             "$HOME/.vimrc"
link "$HOME_DIR/.config/git/ignore" "$HOME/.config/git/ignore"

# -----------------------------------------------------------------------------
# 5. Configure iTerm2 to load preferences from this repo (no manual step)
# -----------------------------------------------------------------------------
echo ""
echo "==> Configuring iTerm2 preferences folder..."

ITERM2_PREFS="$DOTFILES_DIR/iterm2"

if [ -d "$ITERM2_PREFS" ]; then
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_PREFS"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  echo "    iTerm2 will load prefs from: $ITERM2_PREFS"
  echo "    Restart iTerm2 for this to take effect."
else
  echo "    [skip] $ITERM2_PREFS not found"
fi

# -----------------------------------------------------------------------------
echo ""
echo "==> All done!"
echo ""
echo "    Next steps:"
echo "    1. Restart iTerm2 — it will load your profiles, colors, and font settings"
echo "    2. Open a new terminal tab to activate the Zsh config"
echo ""
