#!/bin/bash

# make sure we are in the home directory
cd ~

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# enable brew in current shell manually
eval "$(/opt/homebrew/bin/brew shellenv)"

# install cli tools
brew install sevenzip git git-flow gh stow nushell tmux zellij yazi zoxide jesseduffield/lazygit/lazygit neovim gcc fzf ripgrep fd uv

# install dotfiles
git clone https://github.com/ferdinandkeller/dotfiles.git
stow -t ~ dotfiles

# install apps
brew install --cask font-jetbrains-mono-nerd-font 1password 1password-cli ghostty visual-studio-code docker google-chrome

# install oh-my-zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# lazy vim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
