#!/bin/sh
# Started at login by ~/Library/LaunchAgents/com.timluo.tmux-restore.plist.
# Starts the tmux server so tmux-continuum's auto-restore fires after a reboot.
# Guard: only restore explicitly if the server came up with no sessions, so we
# never double-restore (when continuum already did) or clobber a live session.

TMUX_BIN=/usr/local/bin/tmux

# Start the server (sources ~/.tmux.conf -> TPM -> continuum auto-restore).
"$TMUX_BIN" start-server

# Give continuum a moment to restore on its own.
sleep 5

# Fallback: if nothing got restored, do it ourselves.
if [ -z "$("$TMUX_BIN" list-sessions 2>/dev/null)" ]; then
  "$TMUX_BIN" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
fi
