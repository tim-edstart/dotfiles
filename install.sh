#!/usr/bin/env bash
# One command from a fresh machine to a working setup:
#
#   git clone https://github.com/tim-edstart/dotfiles ~/.dotfiles && ~/.dotfiles/install.sh
#
# It installs the tools (zsh, tmux, neovim, git, ripgrep, fd, fzf, jq, gh, python3, cmake,
# a C compiler, mise for every language runtime, Powerlevel10k and its font), links every
# config, makes zsh the login shell, installs tmux and nvim plugins, the Kotlin language
# server and the iTerm2 theme. Re-running only changes what is missing.
#
#   ./install.sh            everything
#   ./install.sh --no-deps  links, plugins and shell only; no package installs
#   ./install.sh --help
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
WITH_DEPS=1
[[ "${1:-}" == "--no-deps" ]] && WITH_DEPS=0
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
ARCH="$(uname -m)"
[[ "$OS" == "Darwin" && "$(sysctl -n hw.optional.arm64 2>/dev/null)" == 1 ]] && ARCH=arm64  # a Rosetta shell says x86_64
info "platform: $PLATFORM ($ARCH)"

link() {  # link <source-in-repo> <target>
  local src="$DOTFILES/$1" dst="$2"
  [[ -e "$src" ]] || { warn "missing $src, skipping"; return; }
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    [[ "$(readlink "$dst")" == "$src" ]] && return
    rm "$dst"
  elif [[ -e "$dst" ]]; then mv "$dst" "$dst.bak-$TS"; warn "backed up $dst -> $dst.bak-$TS"; fi
  ln -s "$src" "$dst"
  info "linked $dst -> $src"
}

brew_arm() { [[ "$ARCH" == arm64 && -x /opt/homebrew/bin/brew ]] && arch -arm64 /opt/homebrew/bin/brew "$@" || brew "$@"; }

install_fonts() {  # MesloLGS NF: what the prompt and the tmux status bar draw their glyphs with
  local dir="$HOME/Library/Fonts"; [[ "$OS" == "Linux" ]] && dir="$HOME/.local/share/fonts"
  mkdir -p "$dir"
  local f; for f in Regular Bold Italic "Bold Italic"; do
    [[ -f "$dir/MesloLGS NF $f.ttf" ]] || curl -fsSL -o "$dir/MesloLGS NF $f.ttf" \
      "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${f// /%20}.ttf" || warn "font $f did not download"
  done
  [[ "$OS" == "Linux" ]] && command -v fc-cache >/dev/null && fc-cache -f "$dir" >/dev/null || true
}

install_deps() {
  local core="zsh tmux neovim git ripgrep fd fzf jq gh python3 curl unzip cmake"
  if [[ "$OS" == "Darwin" ]]; then
    xcode-select -p >/dev/null 2>&1 || { info "installing the Xcode command line tools (clang, make)"; xcode-select --install || true; }
    if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    brew_arm install $core mise powerlevel10k || true
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y zsh tmux neovim git ripgrep fd-find fzf jq gh python3 curl unzip cmake build-essential clang || true
    command -v fdfind >/dev/null 2>&1 && mkdir -p "$HOME/bin" && ln -sf "$(command -v fdfind)" "$HOME/bin/fd"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh tmux neovim git ripgrep fd-find fzf jq gh python3 curl unzip cmake gcc-c++ clang || true
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm zsh tmux neovim git ripgrep fd fzf jq github-cli python curl unzip cmake base-devel clang || true
  else
    warn "No known package manager found — install $core manually."
  fi
  if [[ "$OS" != "Darwin" ]]; then
    command -v mise >/dev/null 2>&1 || { info "installing mise"; curl -fsSL https://mise.run | sh; }
    [[ -d "$HOME/.local/share/powerlevel10k" ]] || git clone --depth 1 https://github.com/romkatv/powerlevel10k "$HOME/.local/share/powerlevel10k"
  fi
  export PATH="$HOME/.local/bin:$PATH"
  if [[ "$IS_WSL" == 1 ]]; then
    warn "WSL: install the MesloLGS NF font on the Windows side and pick it in Windows Terminal."
  else
    install_fonts
  fi
}

[[ "$WITH_DEPS" == 1 ]] && { info "installing tools"; install_deps; }

info "linking configs"
link nvim              "$HOME/.config/nvim"
link vim               "$HOME/.vim"
link vim/vimrc         "$HOME/.vimrc"
link tmux/tmux.conf    "$HOME/.tmux.conf"
link zsh/zshrc         "$HOME/.zshrc"
link zsh/zshenv        "$HOME/.zshenv"
link zsh/p10k.zsh      "$HOME/.p10k.zsh"
link git/gitconfig     "$HOME/.gitconfig"
link mise/config.toml  "$HOME/.config/mise/config.toml"
link claude/skills/nvim "$HOME/.claude/skills/nvim"
[[ -f "$DOTFILES/git/gitignore_global" ]] && link git/gitignore_global "$HOME/.gitignore_global"

# Terminal emulator configs: desktop only. On WSL the GUI terminal runs on
# Windows, so linking these into the WSL home is pointless — skip.
if [[ "$IS_WSL" == 0 ]]; then
  for t in alacritty kitty wezterm; do
    [[ -d "$DOTFILES/terminal/$t" ]] && link "terminal/$t" "$HOME/.config/$t"
  done
fi

# ~/.zshrc.local for secrets (never tracked)
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$DOTFILES/zsh/zshrc.local.example" "$HOME/.zshrc.local"
  warn "created ~/.zshrc.local — fill in your secrets there (it is gitignored)"
fi

# zsh as the login shell
if [[ "$(basename "${SHELL:-}")" != "zsh" ]] && command -v zsh >/dev/null 2>&1; then
  if [[ -t 0 ]]; then info "making zsh the login shell"; chsh -s "$(command -v zsh)" || warn "chsh failed; run: chsh -s $(command -v zsh)"
  else warn "login shell is not zsh; run: chsh -s $(command -v zsh)"; fi
fi

# language runtimes from mise/config.toml (node, python, java, rust, go); projects override per directory
if command -v mise >/dev/null 2>&1 && [[ "$WITH_DEPS" == 1 ]]; then
  info "installing language runtimes with mise (this is the slow step the first time)"
  mise install --yes || warn "mise install had trouble; run: mise install"
fi

# tmux plugin manager
TPM="$HOME/.tmux/plugins/tpm"
[[ -d "$TPM" ]] || { info "installing tpm"; git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"; }
"$TPM/bin/install_plugins" >/dev/null 2>&1 || warn "run prefix+I inside tmux to finish plugin install"
tmux source-file "$HOME/.tmux.conf" >/dev/null 2>&1 || true   # a running server picks the config up now

# nvim: sync plugins headless (lazy.nvim bootstraps itself from init.lua); language servers
# install themselves through mason the first time nvim opens.
if command -v nvim >/dev/null 2>&1; then
  info "syncing nvim plugins (headless)"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || warn "open nvim and run :Lazy sync"
else
  warn "nvim not installed — re-run without --no-deps, or install it, then re-run."
fi

# Kotlin language server (JetBrains builds expire monthly; nvim keeps this fresh via :KotlinLspUpdate)
if [[ "$ARCH" == arm64 || "$ARCH" == aarch64 ]]; then
  "$DOTFILES/bin/kotlin-lsp-update" || warn "kotlin-lsp did not install; run bin/kotlin-lsp-update later"
else
  warn "kotlin-lsp only ships arm64 builds; Kotlin falls back to no LSP on $ARCH"
fi

# iTerm2: IntelliJ Dark colours, MesloLGS NF, minimal tabs
if [[ "$OS" == "Darwin" && -f "$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]]; then
  "$DOTFILES/bin/iterm2-theme" || warn "iTerm2 theme not applied; run bin/iterm2-theme"
fi

info "done."
cat <<MSG
  next:  exec zsh            (or open a new terminal window)
         dev                 in any project: what it can run and what is running
         prefix + t in tmux  the dev command center
MSG
