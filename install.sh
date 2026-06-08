#!/bin/sh
# install.sh — wire this repo's skills into the AI harnesses on this machine.
#
# Most harnesses read a shared store, ~/.agents/skills/ — Codex (its native dir),
# opencode, Gemini CLI, and the broader "agent-compatible" ecosystem all read it.
# So skills are symlinked there once. A few tools read ONLY their own directory
# (Claude Code, Cursor); those get an extra symlink. Editing a skill in the repo
# is then live everywhere. Idempotent: safe to re-run.
#
# Usage:
#   ./install.sh [--all] [--force] [--dry-run] [--target DIR] [--help]
#
#   --all         also link into exception harnesses that aren't installed yet
#   --force       replace a real dir / foreign symlink of the same name
#   --dry-run     print what would happen, change nothing
#   --target DIR  also link into an extra skills directory (repeatable)
#   --help        show this help

set -eu

# --- where skills go --------------------------------------------------------
# CANONICAL is the shared store almost every tool reads; we always link here.
CANONICAL="$HOME/.agents/skills"

# EXCEPTIONS: harnesses that read ONLY their own dir, not the shared store.
# One per line: "<name> | <skills dir>". Linked only if the harness is installed
# (its parent dir exists) or --all is given. Add a line if you use another tool
# that doesn't read ~/.agents/skills.
EXCEPTIONS="
claude-code | $HOME/.claude/skills
cursor      | $HOME/.cursor/skills
"

# --- args --------------------------------------------------------------------
ALL=0 FORCE=0 DRY=0 EXTRA_TARGETS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --all)     ALL=1 ;;
    --force)   FORCE=1 ;;
    --dry-run) DRY=1 ;;
    --target)  shift; [ $# -gt 0 ] || { echo "--target needs a DIR" >&2; exit 2; }
               EXTRA_TARGETS="$EXTRA_TARGETS custom|$1" ;;
    --help|-h) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
  shift
done

# --- locate repo + skills ----------------------------------------------------
REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO/skills"
[ -d "$SKILLS_DIR" ] || { echo "no skills/ dir next to install.sh" >&2; exit 1; }

# Collect skill names (every skills/*/ that holds a SKILL.md).
SKILLS=""
for d in "$SKILLS_DIR"/*/; do
  [ -f "$d/SKILL.md" ] || continue
  SKILLS="$SKILLS ${d%/}"
done
[ -n "$SKILLS" ] || { echo "no skills found under $SKILLS_DIR" >&2; exit 1; }

run() { # echo + (unless dry-run) execute
  if [ "$DRY" -eq 1 ]; then printf '   would: %s\n' "$*"; else "$@"; fi
}

# Resolve a symlink's target to an absolute path (readlink -f isn't on macOS).
symlink_target_abs() { # <symlink>
  link="$1"; tgt="$(readlink "$link")" || return 1
  case "$tgt" in
    /*) printf '%s\n' "$tgt" ;;
    *)  printf '%s\n' "$(cd "$(dirname "$link")" && cd "$(dirname "$tgt")" 2>/dev/null && pwd)/$(basename "$tgt")" ;;
  esac
}

# True if <dest> is a symlink that already points into this repo's skills/.
ours() { # <dest>
  [ -L "$1" ] || return 1
  case "$(symlink_target_abs "$1")" in "$SKILLS_DIR"/*) return 0 ;; *) return 1 ;; esac
}

link_one() { # <skill path> <target dir>
  src="$1"; target_dir="$2"; name="$(basename "$src")"; dest="$target_dir/$name"
  if ours "$dest"; then
    # our own symlink — repoint it (idempotent, picks up repo moves)
    run ln -sfn "$src" "$dest"; printf '   linked  %s\n' "$dest"
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    # a real dir, or a foreign symlink pointing at someone else's skill —
    # never hijack it silently. Replace only on explicit --force.
    what="real dir"; [ -L "$dest" ] && what="foreign symlink"
    if [ "$FORCE" -eq 1 ]; then
      run rm -rf "$dest"; run ln -sfn "$src" "$dest"
      printf '   replaced %s (was a %s)\n' "$dest" "$what"
    else
      printf '   SKIP    %s — a %s already owns this name (use --force)\n' "$dest" "$what"
    fi
  else
    run ln -sfn "$src" "$dest"; printf '   linked  %s\n' "$dest"
  fi
}

process_target() { # <name> <skills dir> <installed:0|1>
  hname="$1"; sdir="$2"; installed="$3"
  if [ "$installed" -eq 0 ] && [ "$ALL" -eq 0 ]; then
    printf '%-12s skip (not installed: %s)\n' "$hname" "$(dirname "$sdir")"
    return
  fi
  printf '%-12s %s\n' "$hname" "$sdir"
  run mkdir -p "$sdir"
  for s in $SKILLS; do link_one "$s" "$sdir"; done
}

echo "Repo:   $REPO"
printf 'Skills:'; for s in $SKILLS; do printf ' %s' "$(basename "$s")"; done; echo
[ "$DRY" -eq 1 ] && echo "(dry run — nothing will change)"
echo

# Shared store — always linked (Codex, opencode, Gemini, … read this).
process_target "agents" "$CANONICAL" 1

# Own-dir exceptions — linked only when installed (or --all).
echo "$EXCEPTIONS" | while IFS='|' read -r raw_name raw_dir; do
  name="$(echo "$raw_name" | tr -d '[:space:]')"
  [ -n "$name" ] || continue
  dir="$(echo "$raw_dir" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -d "$(dirname "$dir")" ]; then process_target "$name" "$dir" 1
  else process_target "$name" "$dir" 0; fi
done

# Extra --target dirs (always treated as installed).
for entry in $EXTRA_TARGETS; do
  dir="${entry#custom|}"
  process_target "custom" "$dir" 1
done

echo
if [ "$DRY" -eq 1 ]; then
  echo "Dry run complete. Re-run without --dry-run to apply."
else
  echo "Done. Re-run after adding a skill or installing a new harness."
fi
