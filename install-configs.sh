#!/bin/sh
# install-configs.sh — symlink this repo's harness configs into place.
#
# Each harness's config files (and any plugin files) live in harnesses/<name>/ and
# are symlinked into the harness's real config location, so the repo is the source
# of truth and edits are live everywhere. An existing real file is backed up first
# (never destroyed). Only harnesses that are installed are touched; the rest are
# skipped and reported. Idempotent.
#
# These are personal configs (model choice, the merge guard, …) — fork/adapt them
# rather than installing mine verbatim if you're not me.
#
# Usage:
#   ./install-configs.sh [--force] [--dry-run] [--only GROUP] [--help]
#
#   --force     replace a real file / foreign symlink without keeping a backup
#   --dry-run   print what would happen, change nothing
#   --only      install one group: claude, claude-agents, or opencode
#   --help      show this help

set -eu

# --- what maps where --------------------------------------------------------
# "<group> | <base dir> | <repo file> | <target>". The group is "installed"
# when <base dir> exists. Add Codex/Pi once installed, e.g.:
#   codex | $HOME/.codex | harnesses/codex/config.toml | $HOME/.codex/config.toml
ENTRIES="
claude   | $HOME/.claude          | harnesses/claude/settings.json            | $HOME/.claude/settings.json
claude-agents | $HOME/.claude     | harnesses/claude/agents/code-conformance.md      | $HOME/.claude/agents/code-conformance.md
claude-agents | $HOME/.claude     | harnesses/claude/agents/conformance-reviewer.md  | $HOME/.claude/agents/conformance-reviewer.md
opencode | $HOME/.config/opencode | harnesses/opencode/opencode.jsonc         | $HOME/.config/opencode/opencode.jsonc
opencode | $HOME/.config/opencode | harnesses/opencode/plugins/merge-guard.js | $HOME/.config/opencode/plugins/merge-guard.js
"

FORCE=0 DRY=0 ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --force)   FORCE=1 ;;
    --dry-run) DRY=1 ;;
    --only)    shift; [ $# -gt 0 ] || { echo "--only needs a GROUP" >&2; exit 2; }
               ONLY="$1" ;;
    --help|-h) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
  shift
done

case "$ONLY" in
  ""|claude|claude-agents|opencode) ;;
  *) echo "unknown --only group: $ONLY" >&2; exit 2 ;;
esac

REPO="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S 2>/dev/null || echo backup)"

run() { if [ "$DRY" -eq 1 ]; then printf '   would: %s\n' "$*"; else "$@"; fi; }

# Absolute target of a symlink (readlink -f isn't on macOS).
link_abs() {
  tgt="$(readlink "$1")" || return 1
  case "$tgt" in
    /*) printf '%s\n' "$tgt" ;;
    *)  printf '%s\n' "$(cd "$(dirname "$1")" && cd "$(dirname "$tgt")" 2>/dev/null && pwd)/$(basename "$tgt")" ;;
  esac
}

# True if dest is a symlink already pointing into this repo.
ours() {
  [ -L "$1" ] || return 1
  case "$(link_abs "$1")" in "$REPO"/*) return 0 ;; *) return 1 ;; esac
}

link_file() { # <repo file> <target>
  src="$REPO/$1"; dest="$2"
  if [ ! -f "$src" ]; then printf '   MISSING %s (not in repo)\n' "$1"; return; fi
  run mkdir -p "$(dirname "$dest")"
  if ours "$dest"; then
    run ln -sfn "$src" "$dest"; printf '   linked   %s\n' "$dest"
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    what="file"; [ -L "$dest" ] && what="foreign symlink"
    if [ "$FORCE" -eq 1 ]; then
      run rm -f "$dest"; run ln -sfn "$src" "$dest"
      printf '   replaced %s (was a %s, --force)\n' "$dest" "$what"
    else
      bak="$dest.bak.$STAMP"
      run mv "$dest" "$bak"; run ln -sfn "$src" "$dest"
      printf '   linked   %s (backed up -> %s)\n' "$dest" "$bak"
    fi
  else
    run ln -sfn "$src" "$dest"; printf '   linked   %s\n' "$dest"
  fi
}

echo "Repo: $REPO"
[ "$DRY" -eq 1 ] && echo "(dry run — nothing will change)"
echo

echo "$ENTRIES" | while IFS='|' read -r raw_name raw_base raw_src raw_dest; do
  name="$(echo "$raw_name" | tr -d '[:space:]')"; [ -n "$name" ] || continue
  [ -z "$ONLY" ] || [ "$name" = "$ONLY" ] || continue
  base="$(echo "$raw_base" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  src="$(echo "$raw_src"   | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  dest="$(echo "$raw_dest" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -d "$base" ]; then
    printf '%-9s %s\n' "$name" "$dest"; link_file "$src" "$dest"
  else
    printf '%-9s skip (not installed: %s)\n' "$name" "$base"
  fi
done

echo
if [ "$DRY" -eq 1 ]; then echo "Dry run complete."; else echo "Done."; fi
