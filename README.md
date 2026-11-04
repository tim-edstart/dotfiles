# dotfiles

My personal dev environment — Neovim, tmux, zsh, git, and terminal emulators —
with a one-command bootstrap for a fresh machine (macOS, Linux, or WSL).

## Quick start

```bash
git clone https://github.com/tim-edstart/dotfiles ~/.dotfiles
~/.dotfiles/install.sh --deps      # installs tools, then symlinks everything
```

Already have the tools? Drop `--deps` to just symlink configs:

```bash
~/.dotfiles/install.sh
```

The installer is **idempotent** and **non-destructive**: any existing file it
would replace is moved to `<file>.bak-<timestamp>` first.

## What's included

| Path | Links to | Notes |
|------|----------|-------|
| `nvim/` | `~/.config/nvim` | lazy.nvim bootstraps itself; `lazy-lock.json` pins versions |
| `tmux/tmux.conf` | `~/.tmux.conf` | tpm + resurrect/continuum; installer clones tpm |
| `zsh/zshrc` | `~/.zshrc` | secrets sourced from `~/.zshrc.local` (see below) |
| `zsh/zshenv` | `~/.zshenv` | |
| `git/gitconfig` | `~/.gitconfig` | uses `gh` as the credential helper |
| `terminal/{alacritty,kitty,wezterm}` | `~/.config/*` | desktop only; skipped on WSL |
| `bin/kotlin-lsp-update` | — | reinstalls JetBrains' kotlin-lsp when a build expires; nvim runs it itself |

## Secrets

**No credentials live in this repo.** `~/.zshrc` sources `~/.zshrc.local`, which
is gitignored. On first run the installer copies `zsh/zshrc.local.example` to
`~/.zshrc.local` for you to fill in (Maven keys, DB creds, cloud auth, etc.).

## Platform notes

- **macOS** — `--deps` uses Homebrew (installs it if missing) and includes the
  GUI terminal casks + Open Sans.
- **Linux** — `--deps` uses `apt`, `dnf`, or `pacman` (auto-detected).
- **WSL** — treated as Linux. Terminal-emulator configs are **skipped** because
  the GUI terminal (e.g. Windows Terminal) runs on the Windows host, not inside
  WSL. Everything else (nvim, tmux, zsh, git) works normally.
- **Native Windows (no WSL)** — not supported directly; install WSL first
  (`wsl --install` in an admin PowerShell), then run the quick-start inside it.

## Credits

The Neovim configuration is adapted from
[wookayin/dotfiles](https://github.com/wookayin/dotfiles). Thanks!

## License

MIT — see [LICENSE](LICENSE).
