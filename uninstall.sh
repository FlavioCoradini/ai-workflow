#!/bin/sh
# uninstall.sh — remove only the skill symlinks that point back into this repo.
#
# Walks the same harness skills directories install.sh uses and deletes any
# symlink whose target resolves inside this repo's skills/ dir. Real folders,
# and symlinks owned by something else, are left untouched.
#
# Usage: ./uninstall.sh [--dry-run] [--target DIR] [--help]

set -eu

# Directories to sweep. Covers the current model (shared store + own-dir
# exceptions) plus legacy paths older versions linked into, so uninstall fully
# cleans up regardless of which version installed. Only symlinks that resolve
# back into this repo are removed — anything else is left alone.
SWEEP_DIRS="
$HOME/.agents/skills
$HOME/.claude/skills
$HOME/.cursor/skills
$HOME/.config/opencode/skill
$HOME/.config/opencode/skills
$HOME/.gemini/skills
$HOME/.pi/skills
$HOME/.qwen/skills
"

DRY=0 EXTRA_TARGETS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --target)  shift; [ $# -gt 0 ] || { echo "--target needs a DIR" >&2; exit 2; }
               EXTRA_TARGETS="$EXTRA_TARGETS $1" ;;
    --help|-h) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
  shift
done

REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO/skills"

# Resolve a symlink target to an absolute path (readlink -f isn't on macOS).
resolve() {
  link="$1"; tgt="$(readlink "$link")" || return 1
  case "$tgt" in
    /*) printf '%s\n' "$tgt" ;;
    *)  printf '%s\n' "$(cd "$(dirname "$link")" && cd "$(dirname "$tgt")" && pwd)/$(basename "$tgt")" ;;
  esac
}

run() { if [ "$DRY" -eq 1 ]; then printf '   would: %s\n' "$*"; else "$@"; fi; }

sweep() { # <skills dir>
  sdir="$1"; [ -d "$sdir" ] || return 0
  for dest in "$sdir"/*; do
    [ -L "$dest" ] || continue
    abs="$(resolve "$dest")" || continue
    case "$abs" in
      "$SKILLS_DIR"/*) run rm "$dest"; printf '   removed %s\n' "$dest" ;;
    esac
  done
}

[ "$DRY" -eq 1 ] && echo "(dry run — nothing will change)"
for dir in $SWEEP_DIRS; do printf '%s\n' "$dir"; sweep "$dir"; done
for dir in $EXTRA_TARGETS; do printf '%s\n' "$dir"; sweep "$dir"; done
echo "Done."
