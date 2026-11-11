---
name: nvim
description: Open a pull request, the worktree this session is working in, or a named branch in Neovim, in its own tmux window shown in iTerm2, so Tim can review it with code navigation. A pull request opens with every changed file in its own tab. Use when Tim says /nvim, "open PR 2109 in nvim", "open this PR in my editor", "open this in nvim", "let me review this locally", or asks to look at a PR or branch in his editor.
---

Open code in Neovim via `cv` (from ~/.dotfiles/bin).

## A pull request

Use this for a PR number or URL, or for "this PR" when one is under discussion.

1. From inside the PR's repository, run `~/.dotfiles/bin/cv --pr <number or URL>`.
   - It fetches the PR and opens a tmux window named `#<number>`.
   - It uses the head branch's own worktree if there is one. Otherwise it makes a detached one at
     `<repo>/.claude/worktrees/review-<branch, / as ->`. On later runs it moves that worktree to the
     PR's latest head, unless it has local edits.
   - It finds the changed files against the PR's own base branch, so a stacked PR shows only its own
     files. Each changed file opens in its own tab and is also in the quickfix list.
2. Reply in one line: the PR, and "gt / gT between the N tabs, ]q / [q to step through them".

On a colleague's PR, edits in the review worktree stay local: never commit or push from it.

## A branch, or this session's work

1. Work out the directory:
   - If Tim named a branch, find its worktree with `git worktree list | grep '\[<branch>\]'`.
   - Otherwise use the worktree this session last edited files in. If you only worked in the
     current directory, use `$PWD`.
   - If the branch has no worktree yet, make one:
     `git worktree add <repo>/.claude/worktrees/review-<branch, / as -> <branch>`.
2. Run `~/.dotfiles/bin/cv <dir>`. It opens a tmux window named after the branch, runs Neovim with the
   branch's changed files in the quickfix list, and brings iTerm2 to the front.
3. Reply in one line: the branch, and "]q / [q to step through the N changed files".
