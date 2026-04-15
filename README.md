# dotfiles

My terminal configuration for iTerm2 + Oh My Zsh + Powerlevel10k.

## What's included

| File/Folder | Purpose |
|---|---|
| `home/.zshrc` | Zsh config — plugins, exports, pyenv/nvm/android paths |
| `home/.p10k.zsh` | Powerlevel10k prompt layout |
| `home/.gitconfig` | Git aliases and settings |
| `home/.vimrc` | Vim config |
| `home/.config/git/ignore` | Global gitignore |
| `fonts/` | MesloLGS NF fonts required by Powerlevel10k |
| `iterm2/` | iTerm2 profiles, colors, keybindings |
| `setup.sh` | Bootstrap script — installs everything automatically |

## Setup on a new machine

```bash
# 1. Clone
git clone https://github.com/<your-username>/dotfiles ~/dotfiles

# 2. Run bootstrap
bash ~/dotfiles/setup.sh
```

The script automatically:
- Installs MesloLGS NF fonts to `~/Library/Fonts/`
- Installs [Oh My Zsh](https://ohmyz.sh/) (if not already installed)
- Clones Powerlevel10k, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting
- Symlinks all config files from `home/` to `$HOME`
- Configures iTerm2 to load preferences from `dotfiles/iterm2/` automatically

After the script finishes: **restart iTerm2 and open a new tab** — everything will look exactly the same.

## Keeping configs in sync

Since the files in `$HOME` are symlinks, any edits you make take effect immediately in the repo. Just `git add` and commit as usual.

For iTerm2: to save current iTerm2 settings into the repo run:
```bash
cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/dotfiles/iterm2/com.googlecode.iterm2.plist
```
Or enable **"Save changes to folder when iTerm2 quits"** in iTerm2 → Preferences → General → Preferences.
