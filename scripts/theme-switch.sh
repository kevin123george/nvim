#!/usr/bin/env bash
# Interactive TUI theme switcher for Ghostty + Oh My Posh

GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
OMP_THEMES_DIR="$(brew --prefix oh-my-posh 2>/dev/null)/themes"

THEMES=(
  "catppuccin|Catppuccin Mocha|Catppuccin Latte|catppuccin"
  "tokyo|TokyoNight|TokyoNight Day|tokyo"
  "nord|Nord|Nord Light|nordtron"
  "kanagawa|Kanagawa Wave|Kanagawa Lotus|catppuccin"
  "gruvbox|Gruvbox Dark|Gruvbox Light|gruvbox"
  "rose-pine|Rose Pine|Rose Pine Dawn|catppuccin"
  "dracula|Dracula+|Catppuccin Latte|catppuccin"
)

get_field() { echo "$1" | cut -d'|' -f"$2"; }

apply_theme() {
  local entry="$1"
  local dark light omp
  dark=$(get_field "$entry" 2)
  light=$(get_field "$entry" 3)
  omp=$(get_field "$entry" 4)

  sed -i '' "s|^theme = .*|theme = \"light:${light},dark:${dark}\"|" "$GHOSTTY_CONFIG"

  if [[ -n "$OMP_THEMES_DIR" && -f "$OMP_THEMES_DIR/${omp}.omp.json" ]]; then
    cp "$OMP_THEMES_DIR/${omp}.omp.json" "$HOME/themes.json"
  fi
}

# ── TUI ───────────────────────────────────────────────────────────────────────
draw() {
  local selected="$1"
  tput cup 2 0
  for i in $(seq 0 $((${#THEMES[@]} - 1))); do
    local entry="${THEMES[$i]}"
    local name dark light
    name=$(get_field "$entry" 1)
    dark=$(get_field "$entry" 2)
    light=$(get_field "$entry" 3)
    if [[ $i -eq $selected ]]; then
      printf "  \033[1;32m▶ %-12s\033[0m  \033[90mdark:\033[0m %-22s \033[90mlight:\033[0m %-20s\033[K\n" \
        "$name" "$dark" "$light"
    else
      printf "    %-12s  \033[90mdark:\033[0m %-22s \033[90mlight:\033[0m %-20s\033[K\n" \
        "$name" "$dark" "$light"
    fi
  done
}

tui() {
  local selected=0
  local count=${#THEMES[@]}

  tput civis
  tput smcup
  trap 'tput cnorm; tput rmcup; exit' INT TERM EXIT

  tput clear
  tput cup 0 0
  printf "\033[1;36m  Ghostty Theme Switcher\033[0m\n"
  printf "\033[90m  ↑↓ navigate   enter apply   q quit\033[0m\n"
  draw "$selected"

  while true; do
    local k1 k2 k3
    IFS= read -rsn1 k1

    if [[ "$k1" == $'\x1b' ]]; then
      IFS= read -rsn1 -t 1 k2
      IFS= read -rsn1 -t 1 k3
      case "${k2}${k3}" in
        '[A') (( selected = (selected - 1 + count) % count )); draw "$selected" ;;
        '[B') (( selected = (selected + 1) % count ));          draw "$selected" ;;
      esac
    elif [[ "$k1" == '' || "$k1" == $'\r' ]]; then
      apply_theme "${THEMES[$selected]}"
      local name
      name=$(get_field "${THEMES[$selected]}" 1)
      tput rmcup
      tput cnorm
      trap - INT TERM EXIT
      echo "Applied: $name — reload Ghostty with Cmd+Shift+,"
      exit 0
    elif [[ "$k1" == 'q' || "$k1" == 'Q' ]]; then
      tput rmcup
      tput cnorm
      trap - INT TERM EXIT
      echo "No changes made."
      exit 0
    fi
  done
}

# ── Direct arg shortcut: ./theme-switch.sh nord ───────────────────────────────
if [[ -n "${1:-}" ]]; then
  arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  if [[ "$arg" =~ ^[0-9]+$ ]] && (( arg >= 1 && arg <= ${#THEMES[@]} )); then
    entry="${THEMES[$((arg-1))]}"
  else
    entry=""
    for t in "${THEMES[@]}"; do
      [[ "$(get_field "$t" 1)" == "$arg" ]] && entry="$t" && break
    done
  fi
  if [[ -z "$entry" ]]; then
    echo "Unknown theme: $1"
    echo "Available: $(for t in "${THEMES[@]}"; do get_field "$t" 1; done | tr '\n' ' ')"
    exit 1
  fi
  apply_theme "$entry"
  echo "Applied: $(get_field "$entry" 1) — reload Ghostty with Cmd+Shift+,"
  exit 0
fi

tui
