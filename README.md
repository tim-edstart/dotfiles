# dotfiles

One command turns a fresh Mac, Linux box or WSL into my working setup: zsh with a
Powerlevel10k prompt, tmux, Neovim with language servers, every language runtime
through mise, and `dev`, a command center that runs anything in a project and shows
what is running.

## Quick start

```bash
git clone https://github.com/tim-edstart/dotfiles ~/.dotfiles && ~/.dotfiles/install.sh
```

At the end it offers to clone `edstart/platform` into `~/IdeaProjects/platform` and runs
`dev doctor` there, which asks for the Maven keys and sets up Docker, Postgres and the
front-end installs (see [Edstart platform](#edstart-platform)).

Then `exec zsh`. The installer is idempotent and non-destructive: it only installs what
is missing, and any file it replaces is kept as `<file>.bak-<timestamp>`. Secrets go in
`~/.zshrc.local`, which it creates from `zsh/zshrc.local.example` and never commits.
`install.sh --no-deps` links configs and plugins without touching packages.

Pick **MesloLGS NF** as the terminal font if the prompt shows boxes. On macOS the
installer sets it in iTerm2 along with the IntelliJ Dark colours (`bin/iterm2-theme`).

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
| `dev doctor` | check the project's setup and walk through fixing each problem; `:DevDoctor` in nvim |

Tasks come from `.dev.toml` at the project root (`dev init` writes one), from
`dev/projects/*.toml` in this repo for projects I do not want to add files to, and
automatically from Makefiles, `package.json` scripts, `Cargo.toml`, justfiles and Gradle
application projects. Every task runs in the `dev` tmux session, keeps its output in a
window after it ends, and logs to `~/.local/state/dev/<project>/logs/`.

Each git worktree is its own project: its runs, logs and tmux windows (named
`<worktree>/<task>`) are separate, and it gets the same project file as its main checkout.

**What a project file can say** (`dev/projects/platform.toml` uses all of it):

| Key | Means |
|---|---|
| `root`, `remote` | which checkouts it is for: this folder (and its worktrees), or any clone whose origin URL contains `remote` |
| `[env]` | variables every task and check gets; `~` and `$VARS` expand. `$DEV_FILES` is the folder named after the file, for its scripts |
| `[tasks.x]` | `cmd`, `cwd`, `desc`, `group`, `env`, plus: |
| &nbsp;&nbsp;`after` | tasks to start first; a dependency with `ready` is waited for, and skipped if it already answers |
| &nbsp;&nbsp;`ready` | a command that succeeds once the task can be used (the port opening is often too early) |
| &nbsp;&nbsp;`port` | `dev` refuses to start the task while something else listens there, and names the checkout running it |
| &nbsp;&nbsp;`needs` | checks that must pass first; a failing one stops the start with its fix |
| `[checks.x]` | `desc`, `test` (exit 0 = fine; runs after sourcing `~/.zshrc.local`), `fix` (what to do), and either `ask` (a variable `dev doctor` asks for and saves to `~/.zshrc.local`; `secret = true` hides typing) or `run` (a command it offers to run; `wait` seconds to re-check) |
| `[hints.x]` | `match` (a regex) and `say`: printed under a task that fails when its output matches; `\1` inserts a group |

Opening nvim, or `:cd`, in a project with failing checks shows one notification listing
them; `:DevDoctor` opens `dev doctor` in a floating terminal.

### Edstart platform

`dev doctor` in the checkout (or `:DevDoctor`) sets everything up, in order: Docker
Desktop installed and running, JDK 21, the two Maven keys (it asks; ask another platform
developer for them), the Postgres container on 54329 (made by Gradle's `startPostgres`),
the `edstart` database (empty, or load a dev dump with `./gradlew :tools:importDbClone`),
pnpm and each checkout's `node_modules`.

| Task | Port | |
|---|---|---|
| `db` | 54329 | the Docker Postgres, found by port whatever the container is called (`dev/projects/platform/pg`) |
| `admin`, `apply`, `calc`, `login`, `platform`, `workflow` | 8019, 8017, 8013, 8012, 8024, 8025 | servers; each starts `db` first and waits until Postgres answers |
| `admin-ui`, `portal`, `partner-portal` | 8011, 8021, – | front ends (`pnpm dev`) |
| `compile`, `test`, `lint` | | Gradle; `dev test -- --tests '*SomeTest*'` |

Every server task connects to the Docker Postgres as `postgres`, whatever `~/.zshrc.local`
says, and runs on mise's Corretto 21. Only one checkout can run a given server at a time,
because the ports are fixed; `dev` says which checkout to stop. When a task fails, the
lines under it say what the output points to (a missing setting, wrong Maven keys, the
wrong Java, Postgres down, a port held outside `dev`, Kotlin out of memory).

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
| `bin/cv` | on `$PATH` | pick a Claude app session's branch and open its worktree in Neovim, in a tmux window |
| `bin/nvim-check` | on `$PATH` | smoke-tests Neovim and its plugins after an upgrade |
| `claude/skills/nvim` | `~/.claude/skills/nvim` | `/nvim` in a Claude session runs `cv` on that session's worktree |
| `dev/projects/*.toml` | read by `dev` | task definitions, setup checks and failure hints for projects, matched by `root` or `remote` |
| `dev/projects/platform/pg` | called by the platform tasks | finds, starts and checks the platform's Docker Postgres |

## Secrets

**No credentials live in this repo.** `~/.zshrc` sources `~/.zshrc.local`, which is
gitignored. On first run the installer copies `zsh/zshrc.local.example` to
`~/.zshrc.local`; `dev doctor` adds the keys a project needs to it, readable only by you.

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
