#!/bin/bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# enable brew in current shell manually
eval "$(/opt/homebrew/bin/brew shellenv)"

# install cli tools
brew install \
  sevenzip \
  direnv git git-flow gh stow \
  nushell tmux zellij yazi zoxide \
  jesseduffield/lazygit/lazygit jesseduffield/lazydocker/lazydocker \
  neovim gcc fzf ripgrep fd \
  uv \
  helm

# install apps
brew install --cask font-jetbrains-mono-nerd-font 1password 1password-cli ghostty visual-studio-code visual-studio-code@insiders docker google-chrome

# install dotfiles
cd ~
git clone https://github.com/ferdinandkeller/dotfiles.git
cd dotfiles
stow .

# install oh-my-zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# lazy vim
# git clone https://github.com/LazyVim/starter ~/.config/nvim
# rm -rf ~/.config/nvim/.git
