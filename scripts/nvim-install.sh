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

# Java
if command -v java &>/dev/null; then
  CURRENT_JAVA=$(java -version 2>&1 | head -1)
  echo ""
  echo "==> Java already installed: $CURRENT_JAVA"
  echo "Install a different version? (e.g. 17, 21, 23 — leave blank to keep current)"
  read -r JAVA_VERSION
else
  echo ""
  echo "==> No Java found. Which version to install? (e.g. 17, 21, 23 — leave blank to skip)"
  read -r JAVA_VERSION
fi

if [ -n "$JAVA_VERSION" ]; then
  if /usr/libexec/java_home -v "$JAVA_VERSION" &>/dev/null; then
    echo "==> Java $JAVA_VERSION already installed, skipping"
  else
    echo "==> Installing Java $JAVA_VERSION"
    brew install --cask "microsoft-openjdk$JAVA_VERSION"
  fi
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
