---
name: nvim
description: Open the worktree this session is working in (or a named branch) in Neovim, in its own tmux window, so Tim can review it with code navigation. Use when Tim says /nvim, "open this in nvim", "let me review this locally", or asks to look at the branch in his editor.
---

Open the code this session is working on in Neovim via `cv` (from ~/.dotfiles/bin).

1. Work out the directory:
   - If Tim named a branch, find its worktree with `git worktree list | grep '\[<branch>\]'`.
   - Otherwise use the worktree this session last edited files in. If you only worked in the
     current directory, use `$PWD`.
   - If the branch has no worktree yet, make one:
     `git worktree add <repo>/.claude/worktrees/review-<branch, / as -> <branch>`.
2. Run `~/.dotfiles/bin/cv <dir>`. It opens a tmux window named after the branch, runs Neovim with the
   branch's changed files in the quickfix list, and brings iTerm2 to the front.
3. Reply in one line: the branch, and "]q / [q to step through the N changed files".
