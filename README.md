# Usage

To install on a new system
```sh
cat >> ~/.bashrc <<'EOF'
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
EOF
echo ".dotfiles" >> .gitignore
git clone --bare git@github.com:tylanphear/dotfiles "$HOME/.dotfiles"
```

Now re-source `~/.bashrc` and then do a `dotfiles checkout`.
