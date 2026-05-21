#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
terminal_sequences_file="${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences"

python3 "$script_dir/render_targets.py" >/dev/null

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    plasma-apply-colorscheme QuickshellDiploma >/dev/null 2>&1 || true
fi

if pgrep -x foot >/dev/null 2>&1; then
    pkill -SIGUSR1 -x foot >/dev/null 2>&1 || true
fi

if pgrep -x footclient >/dev/null 2>&1; then
    pkill -SIGUSR1 -x footclient >/dev/null 2>&1 || true
fi

if [ ! -f "$terminal_sequences_file" ]; then
    terminal_sequences_file="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/generated/terminal/sequences.txt"
fi

if [ -f "$terminal_sequences_file" ]; then
    for tty in /dev/pts/[0-9]*; do
        [ -w "$tty" ] || continue
        {
            cat "$terminal_sequences_file" > "$tty" 2>/dev/null || true
        } & disown || true
    done
fi
