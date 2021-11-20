# Usage

To install on a new system
```sh
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
echo ".dotfiles" >> "$HOME/.gitignore"
git clone --bare git@github.com:tylanphear/dotfiles "$HOME/.dotfiles"
```

Now do a `dotfiles checkout -f` (warning: will overwrite existing files which conflict).
