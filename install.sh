#!/usr/bin/env bash
# Dotfiles installer — symlinks configs into place and (optionally) installs deps.
# Works on macOS, Linux, and WSL (Ubuntu/Debian, Fedora, Arch).
#
#   ./install.sh            symlink configs + set up tmux/nvim
#   ./install.sh --deps     also install the core tools first (brew/apt/dnf/pacman)
#   ./install.sh --help
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
WITH_DEPS=0
[[ "${1:-}" == "--deps" ]] && WITH_DEPS=1
[[ "${1:-}" == "--help" ]] && { grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

# --- platform detection ---
OS="$(uname -s)"; IS_WSL=0
if [[ "$OS" == "Linux" ]] && grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then IS_WSL=1; fi
case "$OS" in
  Darwin) PLATFORM="macOS" ;;
  Linux)  PLATFORM=$([[ "$IS_WSL" == 1 ]] && echo "WSL" || echo "Linux") ;;
  *) warn "Unsupported OS '$OS'. Native Windows: use WSL (wsl --install) and run this inside it."; exit 1 ;;
esac
info "platform: $PLATFORM"

link() {  # link <source-in-repo> <target>
  local src="$DOTFILES/$1" dst="$2"
  [[ -e "$src" ]] || { warn "missing $src, skipping"; return; }
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then rm "$dst"
  elif [[ -e "$dst" ]]; then mv "$dst" "$dst.bak-$TS"; warn "backed up $dst -> $dst.bak-$TS"; fi
  ln -s "$src" "$dst"
  info "linked $dst -> $src"
}

install_deps() {
  local core="neovim tmux git ripgrep fzf"
  if [[ "$OS" == "Darwin" ]]; then
    command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install $core fd || true
    # GUI terminals + fonts only make sense on desktop macOS
    brew install --cask alacritty kitty wezterm font-open-sans || true
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y neovim tmux git ripgrep fd-find fzf curl || true
    # Debian/Ubuntu ship fd as `fdfind`; expose it as `fd`
    command -v fdfind >/dev/null 2>&1 && mkdir -p "$HOME/bin" && ln -sf "$(command -v fdfind)" "$HOME/bin/fd"
    [[ "$IS_WSL" == 1 ]] && warn "WSL: install terminal emulators/fonts on the Windows side (e.g. Windows Terminal), not in WSL."
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y neovim tmux git ripgrep fd-find fzf curl || true
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm neovim tmux git ripgrep fd fzf curl || true
  else
    warn "No known package manager found — install $core manually."
  fi
}

[[ "$WITH_DEPS" == 1 ]] && { info "installing core tools"; install_deps; }

info "symlinking configs"
link nvim              "$HOME/.config/nvim"
link tmux/tmux.conf    "$HOME/.tmux.conf"
link zsh/zshrc         "$HOME/.zshrc"
link zsh/zshenv        "$HOME/.zshenv"
link git/gitconfig     "$HOME/.gitconfig"
[[ -f "$DOTFILES/git/gitignore_global" ]] && link git/gitignore_global "$HOME/.gitignore_global"

# Terminal emulator configs: desktop only. On WSL the GUI terminal runs on
# Windows, so linking these into the WSL home is pointless — skip.
if [[ "$IS_WSL" == 0 ]]; then
  for t in alacritty kitty wezterm; do
    [[ -d "$DOTFILES/terminal/$t" ]] && link "terminal/$t" "$HOME/.config/$t"
  done
else
  warn "WSL: skipped alacritty/kitty/wezterm configs (they belong on the Windows host)."
fi

# ~/.zshrc.local for secrets (never tracked)
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$DOTFILES/zsh/zshrc.local.example" "$HOME/.zshrc.local"
  warn "created ~/.zshrc.local — fill in your secrets there (it is gitignored)"
fi

# tmux plugin manager
TPM="$HOME/.tmux/plugins/tpm"
[[ -d "$TPM" ]] || { info "installing tpm"; git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"; }
"$TPM/bin/install_plugins" >/dev/null 2>&1 || warn "run prefix+I inside tmux to finish plugin install"

# nvim: sync plugins headless (lazy.nvim bootstraps itself from init.lua)
if command -v nvim >/dev/null 2>&1; then
  info "syncing nvim plugins (headless)"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || warn "open nvim and run :Lazy sync"
else
  warn "nvim not installed — run with --deps, or install it, then re-run."
fi

info "done. Restart your shell:  exec zsh"
