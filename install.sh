#!/bin/bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# enable brew in current shell manually
eval "$(/opt/homebrew/bin/brew shellenv)"

# install cli tools
brew install \
  sevenzip zstd ffmpeg x264 x265 xz gmp gnupg wget tree-sitter \
  git gh jj stow just mise \
  zellij zoxide \
  neovim gcc fzf ripgrep fd httpie yq

# install apps
brew install --cask font-jetbrains-mono-nerd-font 1password 1password-cli ghostty visual-studio-code docker google-chrome claude datagrip slack notion notion-calendar

# install dotfiles (contains personal configuration)
cd ~
git clone https://github.com/ferdinandkeller/dotfiles.git
cd dotfiles
stow .

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# lazy vim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
