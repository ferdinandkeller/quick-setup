#!/bin/bash
# Quick Setup: unattended macOS developer environment
set -uo pipefail

DOTFILES_REPO="https://github.com/ferdinandkeller/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Apps pinned to the Dock, in order. Finder is always first and Trash always last.
# Missing apps are skipped.
DOCK_APPS=(
  "/System/Applications/System Settings.app"
  "/Applications/Ghostty.app"
  "/Applications/1Password.app"
  "/Applications/Claude.app"
  "/Applications/Google Chrome.app"
  "/Applications/Safari.app"
  "/Applications/Mail.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Docker.app"
  "/Applications/DataGrip.app"
  "/Applications/Slack.app"
  "/Applications/Notion.app"
)


log() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------------------
# sudo: ask once up front, then keep the session alive for the whole run
# ---------------------------------------------------------------------------
log "Requesting administrator access (the only prompt of the run)"
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
log "Installing Homebrew"
if [ ! -x /opt/homebrew/bin/brew ]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# enable brew in current shell manually
eval "$(/opt/homebrew/bin/brew shellenv)"

log "Installing CLI tools"
brew install \
  sevenzip zstd ffmpeg x264 x265 xz gmp gnupg wget tree-sitter \
  git gh jj stow just mise \
  zellij zoxide \
  neovim gcc fzf ripgrep fd httpie yq \
  dockutil

log "Installing apps"
brew install --cask \
  font-jetbrains-mono-nerd-font 1password 1password-cli ghostty visual-studio-code \
  docker google-chrome claude datagrip slack notion notion-calendar

# ---------------------------------------------------------------------------
# Oh My Zsh: runs BEFORE stow so it won't overwrite .zshrc
# ---------------------------------------------------------------------------
log "Installing Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ---------------------------------------------------------------------------
# Dotfiles: existing files are moved to a backup folder, then stow links
# ---------------------------------------------------------------------------
log "Installing dotfiles"
if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull --ff-only
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
# stow adopt handles conflicts by pulling the host's version
stow --adopt --no-folding --target="$HOME" .
# restore allows going back to the initial version we wanted
git restore .

# ---------------------------------------------------------------------------
# LazyVim (only if no nvim config exists yet, e.g. from your dotfiles)
# ---------------------------------------------------------------------------
log "Installing LazyVim"
if [ ! -e "$HOME/.config/nvim" ]; then
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi

# ---------------------------------------------------------------------------
# macOS settings
# ---------------------------------------------------------------------------
log "Configuring macOS"
osascript -e 'tell application "System Settings" to quit' 2>/dev/null

# --- Dock ---
# keep the Dock visible
defaults write com.apple.dock autohide -bool false
# no suggested & recent apps
defaults write com.apple.dock show-recents -bool false
# don't reorder Spaces by recent use
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock tilesize -int 48

dockutil --remove all --no-restart
for app in "${DOCK_APPS[@]}"; do
  [ -d "$app" ] && dockutil --add "$app" --no-restart
done
# Downloads: shown as a folder icon, opens as a grid, newest first
dockutil --add "$HOME/Downloads" --section others \
  --view grid --display folder --sort dateadded --no-restart

# --- Don't restore the previous session ---
# don't reopen windows at login
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
# close windows when quitting an app
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# --- Finder ---
# show files extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# column view
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
 # no grouping
defaults write com.apple.finder FXPreferredGroupBy -string "None"
# sort by name
defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"
# search current folder instead of "This Mac"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# hide confirmation window when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# new windows open in ~
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# no .DS_Store on network drives or usb drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

killall Dock Finder SystemUIServer 2>/dev/null

log "Done! Log out and back in so the keyboard settings fully apply."
[ -d "$BACKUP_DIR" ] && echo "Replaced files were backed up to $BACKUP_DIR"

# open link to Umbra page
open "https://replay.software/umbra"
