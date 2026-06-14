#!/usr/bin/env bash
# Ghostty beautiful terminal setup
# Based on: https://kskroyal.com/beautiful-mac-terminal-ghostty/

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Step 1: Homebrew ──────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  info "Homebrew already installed ($(brew --version | head -1))"
fi

# ── Step 2: JetBrains Mono Nerd Font ─────────────────────────────────────────
info "Installing JetBrains Mono Nerd Font..."
brew install --cask font-jetbrains-mono-nerd-font

# ── Step 3: Ghostty terminal ──────────────────────────────────────────────────
if ! [ -d "/Applications/Ghostty.app" ]; then
  info "Installing Ghostty..."
  brew install --cask ghostty
else
  info "Ghostty already installed"
fi

# ── Step 4: Ghostty config ────────────────────────────────────────────────────
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG="$GHOSTTY_CONFIG_DIR/config"
mkdir -p "$GHOSTTY_CONFIG_DIR"

if [ -f "$GHOSTTY_CONFIG" ]; then
  warn "Backing up existing Ghostty config to $GHOSTTY_CONFIG.bak"
  cp "$GHOSTTY_CONFIG" "$GHOSTTY_CONFIG.bak"
fi

info "Writing Ghostty config..."
cat > "$GHOSTTY_CONFIG" <<'EOF'
theme = "light:Catppuccin Latte,dark:Catppuccin Mocha"
font-family = "JetBrainsMono NFM Regular"
font-size = 15
window-padding-x = 10
window-padding-y = 10
window-decoration = true
cursor-style = block
adjust-cell-height = 35%
mouse-scroll-multiplier = 2
window-colorspace = "display-p3"
copy-on-select = clipboard
window-padding-balance = true
window-save-state = always
macos-titlebar-style = transparent
background-opacity = 0.8
background-blur = 90
EOF

# ── Step 5: Oh My Posh ───────────────────────────────────────────────────────
info "Installing Oh My Posh..."
brew install jandedobbeleer/oh-my-posh/oh-my-posh

# Copy a nice default theme to ~/themes.json
OMP_THEMES_DIR="$(brew --prefix oh-my-posh)/themes"
DEFAULT_THEME="catppuccin"

if [ -f "$OMP_THEMES_DIR/${DEFAULT_THEME}.omp.json" ]; then
  info "Copying '${DEFAULT_THEME}' theme to ~/themes.json..."
  cp "$OMP_THEMES_DIR/${DEFAULT_THEME}.omp.json" "$HOME/themes.json"
elif [ -f "$OMP_THEMES_DIR/jandedobbeleer.omp.json" ]; then
  warn "Theme '${DEFAULT_THEME}' not found, using 'jandedobbeleer' instead"
  cp "$OMP_THEMES_DIR/jandedobbeleer.omp.json" "$HOME/themes.json"
else
  warn "Could not find a bundled theme. Creating minimal themes.json..."
  cat > "$HOME/themes.json" <<'EOF'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        { "type": "path", "style": "powerline", "powerline_symbol": "",
          "foreground": "#ffffff", "background": "#61afef",
          "properties": { "style": "folder" } },
        { "type": "git", "style": "powerline", "powerline_symbol": "",
          "foreground": "#ffffff", "background": "#98c379" }
      ],
      "type": "prompt"
    }
  ],
  "final_space": true
}
EOF
fi

# ── Step 5b: Update .zshrc ────────────────────────────────────────────────────
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

add_to_zshrc() {
  local line="$1"
  local marker="$2"  # unique string to grep for to avoid duplicates
  if ! grep -qF "$marker" "$ZSHRC" 2>/dev/null; then
    echo "$line" >> "$ZSHRC"
    info "Added to .zshrc: $marker"
  else
    warn "Already in .zshrc (skipping): $marker"
  fi
}

add_to_zshrc 'eval "$(oh-my-posh init zsh --config ~/themes.json)"' "oh-my-posh init zsh"
add_to_zshrc 'export TERM=xterm-256color' "xterm-256color"

# ── Step 6: zsh-autosuggestions ───────────────────────────────────────────────
info "Installing zsh-autosuggestions..."
brew install zsh-autosuggestions

add_to_zshrc 'source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh' "zsh-autosuggestions"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Next steps:"
echo "  1. Open Ghostty (Cmd+Space → 'Ghostty')"
echo "  2. Run: exec zsh   — to reload your shell config"
echo "  3. Browse themes:  ghostty +list-themes"
echo "  4. Browse Oh My Posh themes: oh-my-posh theme list"
echo "     Then: oh-my-posh theme set <name>  to preview one"
echo ""
echo " Ghostty config: $GHOSTTY_CONFIG"
echo " Oh My Posh theme: ~/themes.json"
echo " To change the OMP theme, copy any file from:"
echo "   $OMP_THEMES_DIR/"
echo "   to ~/themes.json (or edit ~/themes.json directly)"
echo ""
