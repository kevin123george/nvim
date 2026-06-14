#!/bin/bash
set -e

echo "==> Installing Kevin's Neovim setup"

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Core tools
echo "==> Installing packages"
brew install neovim lazygit lazydocker ripgrep fd

# Java 17 (required for Spring Boot projects)
if ! /usr/libexec/java_home -v 17 &>/dev/null; then
  echo "==> Installing Java 17"
  brew install --cask microsoft-openjdk17
fi

# Neovim config
NVIM_CONFIG="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG" ]; then
  echo "==> Backing up existing nvim config to $NVIM_CONFIG.bak"
  mv "$NVIM_CONFIG" "$NVIM_CONFIG.bak"
fi

echo "==> Cloning nvim config"
git clone https://github.com/kevin123george/nvim.git "$NVIM_CONFIG"

echo ""
echo "Done! Open nvim and run :Lazy sync to install plugins."
echo "Then run :MasonInstall jdtls java-debug-adapter"
