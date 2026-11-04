# dotfiles

One command turns a fresh Mac, Linux box or WSL into my working setup: zsh with a
Powerlevel10k prompt, tmux, Neovim with language servers, every language runtime
through mise, and `dev`, a command center that runs anything in a project and shows
what is running.

## Quick start

```bash
git clone https://github.com/tim-edstart/dotfiles ~/.dotfiles && ~/.dotfiles/install.sh
```

Then `exec zsh`. The installer is idempotent and non-destructive: it only installs what
is missing, and any file it replaces is kept as `<file>.bak-<timestamp>`. Secrets go in
`~/.zshrc.local`, which it creates from `zsh/zshrc.local.example` and never commits.
`install.sh --no-deps` links configs and plugins without touching packages.

Pick **MesloLGS NF** as the terminal font if the prompt shows boxes. On macOS the
installer sets it in iTerm2 along with the Kanagawa colours (`bin/iterm2-theme`).

## Daily use

### `dev`: run anything, see everything

| Command | Does |
|---|---|
| `dev` | status of every task the project knows: running or not, since when, ports, exit codes, code changed since start |
| `dev run` | pick a task with fzf and start it in its own tmux window |
| `dev admin` | start the task called `admin` (`dev run admin` works too; `-- args` go to the command) |
| `dev exec name -- cmd…` | run any command as a tracked task |
| `dev stop` / `restart` / `logs -f` / `open` | manage one task |
| `dev top` | live status; in tmux it is `prefix + t`, and `prefix + T` picks a task to run |
| `dev tasks` | every task and where it was found |
| `dev clean` | close the windows of finished tasks and drop old logs |

Tasks come from `.dev.toml` at the project root (`dev init` writes one), from
`dev/projects/*.toml` in this repo for projects I do not want to add files to, and
automatically from Makefiles, `package.json` scripts, `Cargo.toml`, justfiles and Gradle
application projects. Every task runs in the `dev` tmux session, keeps its output in a
window after it ends, and logs to `~/.local/state/dev/<project>/logs/`.

### Finding your way in nvim

`,` is the leader. Fuzzy find with `Ctrl-p` (files) and `Ctrl-g` (text), `,rg` greps the
word under the cursor. Language-server jumps: `gd` definition, `gr` references, `gi`
implementations, `gp` peek, `K` docs, `]d` `[d` diagnostics, `,rn` rename, `,ca` code
actions. `,f` plus a character jumps anywhere on screen. `,E` toggles the file tree.
`Ctrl-h/j/k/l` moves between splits and tmux panes. `:Maps` searches every binding.

### tmux

Window names say where you are and what runs there (`platform`, `platform:nvim`,
`servers:java`); split windows show each pane's directory and command on its border.
The status bar shows the session, the pane's directory, its git branch and the time.
`prefix + |` and `prefix + -` split, `prefix + r` reloads the config, `prefix + Ctrl-s`
and `prefix + Ctrl-r` save and restore sessions (they also survive reboots).

## Languages

`mise/config.toml` installs Node (LTS and 18), Python, Java (Corretto 21), Rust and Go
globally; a project's `.mise.toml`, `.nvmrc` or `.java-version` wins inside it. Neovim
installs language servers through mason the first time it opens a file type (Kotlin,
Java, TypeScript, Python, Rust, C/C++, Go, Lua, Bash, SQL, YAML, JSON, TOML, XML) and
formats with ktlint, prettier, ruff, rustfmt, gofmt and clang-format. Kotlin uses
JetBrains' kotlin-lsp, whose builds expire monthly: nvim replaces it by itself, or run
`:KotlinLspUpdate`.

To add a language: a line in `mise/config.toml`, its server in `auto_lsp_servers`
(`nvim/lua/config/lsp.lua`), its parser in `nvim/lua/config/treesitter.lua`, its
formatter in `nvim/lua/config/formatting.lua`.

## What's included

| Path | Links to | Notes |
|------|----------|-------|
| `nvim/` | `~/.config/nvim` | lazy.nvim bootstraps itself; `lazy-lock.json` pins versions |
| `vim/` | `~/.vim`, `~/.vimrc` | the vimrc nvim sources for its basic settings and keymaps |
| `tmux/tmux.conf` | `~/.tmux.conf` | tpm + resurrect/continuum; installer clones tpm |
| `zsh/zshrc`, `zsh/zshenv`, `zsh/p10k.zsh` | `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh` | secrets sourced from `~/.zshrc.local` |
| `git/gitconfig` | `~/.gitconfig` | uses `gh` as the credential helper |
| `mise/config.toml` | `~/.config/mise/config.toml` | global language runtimes |
| `terminal/{alacritty,kitty,wezterm}` | `~/.config/*` | desktop only; skipped on WSL |
| `bin/dev` | on `$PATH` | the command center |
| `bin/kotlin-lsp-update` | on `$PATH` | reinstalls JetBrains' kotlin-lsp when a build expires |
| `bin/iterm2-theme` | on `$PATH` | iTerm2 colours, font and tab style (macOS) |
| `dev/projects/*.toml` | read by `dev` | task definitions for projects, matched by `root` |

## Secrets

**No credentials live in this repo.** `~/.zshrc` sources `~/.zshrc.local`, which is
gitignored. On first run the installer copies `zsh/zshrc.local.example` to
`~/.zshrc.local` for you to fill in (Maven keys, DB creds, cloud auth, etc.).

## Platform notes

- **macOS** — Homebrew (installed if missing), the Xcode command line tools for C/C++,
  fonts into `~/Library/Fonts`, iTerm2 themed.
- **Linux** — `apt`, `dnf` or `pacman` (auto-detected); Powerlevel10k and mise from
  their installers; fonts into `~/.local/share/fonts`.
- **WSL** — treated as Linux. Terminal-emulator configs and fonts belong on the Windows
  host (Windows Terminal), everything else works normally.
- **Native Windows (no WSL)** — install WSL first (`wsl --install` in an admin
  PowerShell), then run the quick start inside it.

## Credits

The Neovim configuration is adapted from
[wookayin/dotfiles](https://github.com/wookayin/dotfiles). Thanks!

## License

MIT — see [LICENSE](LICENSE).
