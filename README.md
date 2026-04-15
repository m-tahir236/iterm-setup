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
| `iterm2/iTerm2 State.itermexport` | Full iTerm2 export — profiles, blur, colors, keybindings, font |
| `iterm2/com.googlecode.iterm2.plist` | iTerm2 preferences plist (XML) |
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
- Extracts and applies the full iTerm2 export (profiles, blur, colors, font, keybindings)

After the script finishes: **open (or reopen) iTerm2 and open a new tab** — everything will look exactly the same.

## Keeping configs in sync

Since the files in `$HOME` are symlinks, any edits you make take effect immediately in the repo. Just `git add` and commit as usual.

### Saving iTerm2 changes

After changing anything in iTerm2 (blur, colors, profiles, font size, etc.):

1. In iTerm2: **Preferences → General → Preferences → Export All Settings...**
2. Save as `iTerm2 State.itermexport` into `~/dotfiles/iterm2/` (overwrite the existing file)
3. Also re-export the plist for the custom folder sync:
   ```bash
   plutil -convert xml1 ~/Library/Preferences/com.googlecode.iterm2.plist \
     -o ~/dotfiles/iterm2/com.googlecode.iterm2.plist
   ```
4. Commit:
   ```bash
   cd ~/dotfiles && git add iterm2/ && git commit -m "Update iTerm2 preferences"
   ```
