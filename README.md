# dotfiles

My terminal configuration for iTerm2 + Oh My Zsh + Powerlevel10k.

## What's included

| File | Purpose |
|---|---|
| `home/.zshrc` | Zsh config — plugins, exports, pyenv/nvm/android paths |
| `home/.p10k.zsh` | Powerlevel10k prompt layout |
| `home/.gitconfig` | Git aliases and settings |
| `home/.vimrc` | Vim config |
| `home/.config/git/ignore` | Global gitignore |
| `iterm2/` | iTerm2 profiles, colors, keybindings |
| `setup.sh` | Bootstrap script — installs everything and creates symlinks |

## Setup on a new machine

```bash
# 1. Clone
git clone https://github.com/<your-username>/dotfiles ~/dotfiles

# 2. Run bootstrap
cd ~/dotfiles
bash setup.sh
```

The script will:
- Install [Oh My Zsh](https://ohmyz.sh/) (if not already installed)
- Clone Powerlevel10k, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting
- Symlink all config files from `home/` to `$HOME` (backs up any existing files as `.bak`)
- Print instructions for loading iTerm2 preferences

## iTerm2 setup

After cloning, point iTerm2 to the preferences folder:

1. Open iTerm2 → Preferences → General → Preferences
2. Check **"Load preferences from a custom folder or URL"**
3. Set folder to `~/dotfiles/iterm2`
4. Restart iTerm2

To keep prefs in sync, also enable **"Save changes to folder when iTerm2 quits"**.

## Keeping configs up to date

Since the files in `$HOME` are symlinks, any edits you make take effect immediately in the repo. Just `git add` and `git commit` as usual.

For iTerm2: changes are auto-saved to `dotfiles/iterm2/` when iTerm2 quits (if the setting above is enabled).
