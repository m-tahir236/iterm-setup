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
# 5. Apply iTerm2 preferences
# -----------------------------------------------------------------------------
echo ""
echo "==> Applying iTerm2 preferences..."

ITERM2_EXPORT="$DOTFILES_DIR/iterm2/iTerm2 State.itermexport"
ITERM2_PLIST_SRC="$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist"
ITERM2_PLIST_DEST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
ITERM2_CUSTOM_FOLDER="$DOTFILES_DIR/iterm2"

# Quit iTerm2 if running so it doesn't overwrite prefs on exit
if pgrep -x iTerm2 > /dev/null 2>&1; then
  echo "    Quitting iTerm2 to safely apply preferences..."
  osascript -e 'quit app "iTerm2"' 2>/dev/null || true
  sleep 2
fi

if [ -f "$ITERM2_EXPORT" ]; then
  # Extract UserDefaults.plist from the .itermexport archive and apply it
  TMPDIR_ITERM="$(mktemp -d)"
  tar -xzf "$ITERM2_EXPORT" -C "$TMPDIR_ITERM" 2>/dev/null
  if [ -f "$TMPDIR_ITERM/user-defaults/UserDefaults.plist" ]; then
    cp "$TMPDIR_ITERM/user-defaults/UserDefaults.plist" "$ITERM2_PLIST_DEST"
    echo "    [applied] Full iTerm2 settings from .itermexport"
  fi
  rm -rf "$TMPDIR_ITERM"
elif [ -f "$ITERM2_PLIST_SRC" ]; then
  cp "$ITERM2_PLIST_SRC" "$ITERM2_PLIST_DEST"
  echo "    [applied] iTerm2 preferences from plist"
else
  echo "    [skip] No iTerm2 preferences found in $DOTFILES_DIR/iterm2/"
fi

# Tell iTerm2 to keep syncing from this folder going forward
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_CUSTOM_FOLDER"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
echo "    [configured] iTerm2 will sync prefs from: $ITERM2_CUSTOM_FOLDER"

# -----------------------------------------------------------------------------
echo ""
echo "==> All done!"
echo ""
echo "    Next steps:"
echo "    1. Open (or reopen) iTerm2 — all your profiles, blur, colors, and font are applied"
echo "    2. Open a new terminal tab to activate the Zsh config"
echo ""
